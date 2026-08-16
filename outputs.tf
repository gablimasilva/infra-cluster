output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "vpc_id" {
  value = module.eks.vpc_id
}

output "subnet_a_id" {
  value = module.eks.subnet_a_id
}

output "subnet_b_id" {
  value = module.eks.subnet_b_id
}

output "internet_gateway_id" {
  value = module.eks.internet_gateway_id
}
