# terraform-aws-eks-karpenter

This module provisions an **Amazon EKS Cluster** with **Karpenter** for dynamic autoscaling and node provisioning. It creates the VPC, EKS control plane, managed node groups, Karpenter Helm chart, and custom `EC2NodeClass` and `NodePool` for spot/on-demand scaling.

---

## Features:

- EKS cluster with IRSA, addons, and flexible public/private access
- Karpenter Helm deployment using OCI from `us-east-1` (cross-region)
- Dynamic creation of `EC2NodeClass` and `NodePool`
- IAM Roles and OIDC support for secure autoscaling
- Fully configurable via variables (region, VPC CIDR, NAT gateway, etc.)

---

## Usage:

```hcl
module "eks_karpenter" {
  source  = "your-org/eks-karpenter/aws"
  version = "1.0.0"

  cluster_name = "example-cluster"
  region       = "eu-north-1"

  vpc_cidr            = "10.0.0.0/16"
  enable_nat_gateway  = true
  single_nat_gateway  = true

  eks_cluster_version                  = "1.31"
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  enable_irsa                          = true
  enable_cluster_creator_permissions   = true

  instance_type = "t3.medium"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Inputs:

### Required

- **`cluster_name`** *(string)*  
  Name of the EKS cluster.

- **`region`** *(string)*  
  AWS region where the EKS cluster is deployed.

---

### Optional (with defaults)

- **`vpc_cidr`** *(string)*  
  CIDR block for the VPC.  
  Default: `"10.0.0.0/16"`

- **`enable_nat_gateway`** *(bool)*  
  Enable creation of NAT Gateway(s).  
  Default: `true`

- **`single_nat_gateway`** *(bool)*  
  Use a single NAT Gateway instead of one per AZ.  
  Default: `true`

- **`eks_cluster_version`** *(string)*  
  Kubernetes version for EKS.  
  Default: `"1.31"`

- **`cluster_endpoint_private_access`** *(bool)*  
  Enable private API access to the EKS cluster.  
  Default: `true`

- **`cluster_endpoint_public_access`** *(bool)*  
  Enable public API access to the EKS cluster.  
  Default: `true`

- **`enable_irsa`** *(bool)*  
  Enable IAM Roles for Service Accounts (IRSA).  
  Default: `true`

- **`enable_cluster_creator_permissions`** *(bool)*  
  Add admin permissions for the user creating the cluster.  
  Default: `true`

- **`instance_type`** *(string)*  
  EC2 instance type for the default managed node group.  
  Default: `"t3.medium"`

- **`tags`** *(map)*  
  Map of tags to apply to all resources.  
  Default: `{}`

---

## 📤 Outputs

- **`cluster_name`**  
  Name of the created EKS cluster.

- **`cluster_endpoint`**  
  API server endpoint URL for the EKS cluster.

- **`vpc_id`**  
  ID of the created VPC.

- **`private_subnets`**  
  List of private subnet IDs created.

- **`public_subnets`**  
  List of public subnet IDs created.

---

### Requirements:

- Terraform >= 1.3
- AWS CLI configured
- Helm + Kubectl Terraform providers