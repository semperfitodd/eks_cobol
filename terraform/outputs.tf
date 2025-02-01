output "account_number" {
  value = data.aws_caller_identity.this.account_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "private_subnets" {
  value = module.vpc.private_subnets
}
output "public_domain" {
  value = var.domain
}

output "public_domain_id" {
  value = data.aws_route53_zone.public.zone_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

# output "rfp_response_image" {
#   value = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.docker_dynamic_site_repo_name}:${local.timestamp_tag}"
# }