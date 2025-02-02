module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.6.5"

  name           = var.environment
  creation_token = var.environment
  encrypted      = true

  mount_targets              = { for k, v in zipmap(local.availability_zones, module.vpc.private_subnets) : k => { subnet_id = v } }
  security_group_description = "${var.environment} EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      description = "Ingress from VPC private subnets"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  tags = var.tags
}