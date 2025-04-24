output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

# Karpenter outputs — only if enabled
output "karpenter_queue_name" {
  description = "Karpenter interruption queue"
  value       = try(module.karpenter[0].queue_name, null)
}

output "node_group_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = try(module.karpenter[0].node_iam_role_arn, null)
}
