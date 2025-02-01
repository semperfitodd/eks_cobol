output "account_number" {
  value = data.aws_caller_identity.this.account_id
}

output "efs_cobol_0" {
  value = module.efs_cobol_llm.id
}

output "efs_cobol_ml" {
  value = module.efs_cobol_ml.id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "public_domain" {
  value = var.domain
}

output "public_domain_id" {
  value = data.aws_route53_zone.public.zone_id
}

output "s3_bucket_name" {
  value = module.s3_bucket_logs.s3_bucket_id
}

output "secret_name" {
  value = aws_secretsmanager_secret.rds_credentials.name
}