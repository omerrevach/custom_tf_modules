terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

variable "cluster_name" {
  default = "ex-omers_modules"
}

variable "karpenter_service_account_name" {
  default = "karpenter"
}

variable "instance_type" {
  default = "t3.medium"
}

locals {
  region = "eu-north-1"
  vpc_cidr = "10.0.0.0/16"
  tags = {
    Terraform                 = "true"
    Environment               = "dev"
    "karpenter.sh/discovery" = var.cluster_name
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.cluster_name
  cidr = local.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [for i in range(3) : cidrsubnet(local.vpc_cidr, 4, i)]
  public_subnets  = [for i in range(3) : cidrsubnet(local.vpc_cidr, 8, i + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"         = var.cluster_name
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  enable_irsa = true
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
  }

  eks_managed_node_groups = {
    general = {
      instance_type = var.instance_type
      min_size      = 2
      max_size      = 5
      desired_size  = 3

      tags = {
        "karpenter.sh/discovery" = var.cluster_name
      }

      labels = {
        role = "general"
      }
    }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  tags = local.tags
}


resource "aws_iam_service_linked_role" "spot" {
  count = 0
  aws_service_name = "spot.amazonaws.com"
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name                     = var.cluster_name
  enable_v1_permissions           = true
  enable_pod_identity             = true
  create_pod_identity_association = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore   = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2SpotFleetTaggingRole  = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
  }

  depends_on = [module.eks]
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "kube-system"
  chart      = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  version    = "1.1.1"

  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password

  wait             = false
  create_namespace = true

  depends_on = [
    module.eks
  ]

  set {
    name  = "serviceAccount.name"
    value = var.karpenter_service_account_name
  }

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "settings.interruptionQueue"
    value = module.karpenter.queue_name
  }

  set {
    name  = "webhook.enabled"
    value = "false"
  }
}

resource "kubectl_manifest" "karpenter_node_class" {
  depends_on = [helm_release.karpenter]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      amiSelectorTerms:
        - alias: al2@latest
  YAML
}

resource "kubectl_manifest" "karpenter_node_pool" {
  depends_on = [kubectl_manifest.karpenter_node_class]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            kind: EC2NodeClass
            group: karpenter.k8s.aws
            name: default
          requirements:
            - key: karpenter.k8s.aws/instance-category
              operator: In
              values: ["t"]
            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["t3"]
            - key: karpenter.k8s.aws/instance-cpu
              operator: In
              values: ["4"]
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["spot", "on-demand"]
      limits:
        cpu: 300
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML
}