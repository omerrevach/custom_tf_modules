# terraform-aws-eks-karpenter

A flexible, production-ready Terraform module that provisions a complete AWS EKS cluster integrated with [Karpenter](https://karpenter.sh) for dynamic, cost-optimized autoscaling. Supports full customization of VPC, NAT gateways, node groups, and Karpenter configuration.

---

## Features:

- Fully dynamic VPC configuration
- Managed EKS cluster with IRSA enabled
- Autoscaling with Karpenter (via Helm and kubectl manifests)
- Public/private endpoint control
- Node group support (general or specialized roles)
- Tags, labels, Helm options, and more — all configurable

---

## Usage:

```hcl
module "eks_karpenter_cluster" {
  source = "omerrevach/eks-karpenter/aws"
  version = "1.0.5"

  cluster_name = "prod-cluster"
  region       = "eu-north-1"

  cluster_version     = "1.31"
  karpenter_version   = "1.1.1"
  karpenter_service_account_name = "karpenter"

  instance_type       = "t3.medium"
  node_min_size       = 2
  node_max_size       = 5
  node_desired_size   = 3

  vpc_cidr = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  public_subnet_cidrs  = ["10.0.48.0/24", "10.0.49.0/24", "10.0.50.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_private_access          = true
  cluster_endpoint_public_access           = true

  karpenter_instance_categories = ["t"]
  karpenter_instance_families   = ["t3"]
  karpenter_instance_cpus       = ["2", "4"]
  karpenter_capacity_types      = ["spot", "on-demand"]
  karpenter_cpu_limit           = 300

  tags = {
    Terraform   = "true"
    Environment = "prod"
    Project     = "eks-karpenter"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | string | n/a | yes |
| cluster_version | EKS Kubernetes version | string | `"1.31"` | no |
| region | AWS region to deploy into | string | `"eu-north-1"` | no |
| vpc_cidr | CIDR block for the VPC | string | `"10.0.0.0/16"` | no |
| public_subnet_cidrs | List of public subnet CIDRs | list | n/a | yes |
| private_subnet_cidrs | List of private subnet CIDRs | list | n/a | yes |
| enable_nat_gateway | Whether to enable NAT gateway | bool | `true` | no |
| single_nat_gateway | Whether to use a single NAT gateway | bool | `true` | no |
| enable_irsa | Enable IAM roles for service accounts (IRSA) | bool | `true` | no |
| enable_cluster_creator_admin | Grant creator full admin permissions | bool | `true` | no |
| cluster_endpoint_private_access | Enable private access to API server | bool | `true` | no |
| cluster_endpoint_public_access | Enable public access to API server | bool | `true` | no |
| instance_type | Default instance type for general node group | string | `"t3.medium"` | no |
| karpenter_service_account_name | Name of the Karpenter service account | string | `"karpenter"` | no |
| tags | Tags to apply to all resources | map | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| eks_cluster_id | ID of the EKS cluster |
| eks_cluster_name | Name of the EKS cluster |
| karpenter_role_arn | IAM role ARN used by Karpenter |
| vpc_id | ID of the VPC created |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |

---

### Requirements:

- Terraform >= 1.3
- AWS CLI configured
- Helm + Kubectl Terraform providers

---

## Contributing

You're welcome to contribute!  
Feel free to fork the repo, make changes, and open a pull request.

