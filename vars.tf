variable "region" {
  description = "AWS region for EKS and VPC deployment"
  type        = string
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "karpenter_version" {
  description = "Helm chart version for Karpenter"
  type        = string
  default     = "1.1.1"
}

variable "karpenter_service_account_name" {
  description = "Service account name used by Karpenter"
  type        = string
  default     = "karpenter"
}

variable "instance_type" {
  description = "EC2 instance type for managed node group"
  type        = string
  default     = "t3.medium"
}

variable "node_min_size" {
  description = "Minimum size of the managed node group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum size of the managed node group"
  type        = number
  default     = 5
}

variable "node_desired_size" {
  description = "Desired size of the managed node group"
  type        = number
  default     = 3
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.48.0/24", "10.0.49.0/24", "10.0.50.0/24"]
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_irsa" {
  description = "Enable IRSA for the EKS cluster"
  type        = bool
  default     = true
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Enable full access for the cluster creator"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the EKS API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS API server endpoint"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "karpenter_instance_categories" {
  type    = list(string)
  default = ["t"]
}

variable "karpenter_instance_families" {
  type    = list(string)
  default = ["t3"]
}

variable "karpenter_instance_cpus" {
  type    = list(string)
  default = ["4"]
}

variable "karpenter_capacity_types" {
  type    = list(string)
  default = ["spot", "on-demand"]
}

variable "karpenter_cpu_limit" {
  description = "CPU limit for Karpenter NodePool"
  type        = number
  default     = 300
}

variable "enable_karpenter" {
  description = "Whether to enable Karpenter"
  type        = bool
  default     = true
}
