module "postgresql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.13.0"

  name = local.environment

  apply_immediately                   = true
  copy_tags_to_snapshot               = true
  create_monitoring_role              = true
  database_name                       = replace(local.environment, "-", "")
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.this.name
  db_subnet_group_name                = local.environment
  deletion_protection                 = true
  engine                              = "aurora-postgresql"
  engine_mode                         = "provisioned"
  engine_version                      = "16.6"
  iam_database_authentication_enabled = true
  master_username                     = "postgres"
  publicly_accessible                 = true
  storage_encrypted                   = true

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

resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "${local.environment}-aurora-serverless-credentials"
  description             = "${local.environment} aurora username and password"
  recovery_window_in_days = "7"

  depends_on = [module.postgresql]
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode(
    {
      username = module.postgresql.cluster_master_username
      password = module.postgresql.cluster_master_password
    }
  )

  depends_on = [module.postgresql]
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