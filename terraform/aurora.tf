module "postgresql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.13.0"

  name = local.environment

  apply_immediately                   = true
  copy_tags_to_snapshot               = true
  create_monitoring_role              = true
  database_name                       = replace(local.environment, "-", "")
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.this.name
  db_subnet_group_name                = module.vpc.database_subnet_group
  deletion_protection                 = false
  engine                              = "aurora-postgresql"
  engine_mode                         = "provisioned"
  engine_version                      = "16.6"
  iam_database_authentication_enabled = true
  master_username                     = "postgres"
  manage_master_user_password         = false
  master_password                     = random_password.password.result
  publicly_accessible                 = false
  storage_encrypted                   = true

  skip_final_snapshot = true

  subnets = module.vpc.database_subnets
  vpc_id  = module.vpc.vpc_id

  tags = var.tags


  instance_class = "db.serverless"
  instances = {
    readwrite = {}
  }
  serverlessv2_scaling_configuration = {
    min_capacity             = 0
    max_capacity             = 4
    seconds_until_auto_pause = 3600
  }

  security_group_rules = {
    vpc_ingress = {
      description              = "PostgreSQL access from EKS pods"
      protocol                 = "tcp"
      from_port                = 5432
      to_port                  = 5432
      type                     = "ingress"
      source_security_group_id = module.eks.node_security_group_id
    }
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = local.environment
  family      = "aurora-postgresql16"
  description = "RDS default cluster parameter group"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}

resource "random_password" "password" {
  length = 16

  special = false
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "${local.environment}-aurora-serverless-${random_string.this.result}"
  description             = "${local.environment} aurora secrets"
  recovery_window_in_days = "7"

  depends_on = [module.postgresql]
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode(
    {
      connection_endpoint = module.postgresql.cluster_endpoint
      database_name       = module.postgresql.cluster_database_name
      password            = module.postgresql.cluster_master_password
      username            = module.postgresql.cluster_master_username
    }
  )

  depends_on = [module.postgresql]
}