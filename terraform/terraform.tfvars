domain = "brewsentry.com"

ecr_repos = {
  cobol_0                   = "cobol_0",
  cobol_ml_cobol_ingestion  = "cobol_ml_cobol_ingestion",
  cobol_ml_cobol_postgresql = "cobol_ml_cobol_postgresql",
  cobol_ml_raw_generator    = "cobol_ml_raw_generator",
  deepseek                  = "deepseek",
  llm                       = "llm"
}

eks_cluster_version = "1.32"

eks_node_instance_type = "t3.medium"

eks_node_gpu_instance_type = "g4dn.xlarge"

environment = "eks_cobol"

region = "us-east-1"

vpc_cidr = "10.10.0.0/16"
