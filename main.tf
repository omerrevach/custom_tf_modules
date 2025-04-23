module "eks_karpenter_stack" {
  source = "./modules/eks-karpenter-wrapper"

  cluster_name                      = "demo-cluster"
  vpc_cidr                          = "10.10.0.0/16"
  region                            = "eu-north-1"
  instance_type                     = "t3.medium"
  desired_size                      = 2
  min_size                          = 1
  max_size                          = 4
  enable_nat_gateway               = true
  single_nat_gateway               = true
  enable_irsa                      = true
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_private_access  = true
  cluster_endpoint_public_access   = true

  tags = {
    Project = "KarpenterDemo"
    Owner   = "Omer"
  }
}
