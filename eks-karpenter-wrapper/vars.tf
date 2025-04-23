variable "region" {
  default = "eu-north-1"
}

variable "cluster_name" {}
variable "karpenter_service_account_name" {
  default = "karpenter"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "cluster_version" {
  default = "1.31"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "desired_size" {
  default = 2
}
variable "min_size" {
  default = 1
}
variable "max_size" {
  default = 5
}

variable "enable_nat_gateway" {
  default = true
}
variable "single_nat_gateway" {
  default = true
}

variable "enable_irsa" {
  default = true
}
variable "enable_cluster_creator_admin_permissions" {
  default = true
}
variable "cluster_endpoint_private_access" {
  default = true
}
variable "cluster_endpoint_public_access" {
  default = true
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Extra tags to apply"
}
