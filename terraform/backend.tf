terraform {
  backend "s3" {
    bucket = "bsc.sandbox.terraform.state"
    key    = "eks-cobol/terraform.tfstate"
    region = "us-east-2"

    use_lockfile = true
  }
}
