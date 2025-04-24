output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "karpenter_queue_name" {
  description = "Karpenter interruption queue"
  value       = module.karpenter.queue_name
}

output "node_group_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = module.karpenter.node_iam_role_arn
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}
