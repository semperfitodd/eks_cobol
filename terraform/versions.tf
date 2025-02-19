provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "eks_cobol"
      Owners      = "Todd"
      Provisioner = "Terraform"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
  required_version = "1.10.5"
}