data "aws_iam_policy_document" "sagemaker_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

data "aws_iam_policy_document" "sagemaker_s3_access" {
  statement {
    effect  = "Allow"
    actions = ["*"]
    resources = [
      module.s3_bucket_logs.s3_bucket_arn,
      "${module.s3_bucket_logs.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${var.environment}_sagemaker_execution_role"

  assume_role_policy = data.aws_iam_policy_document.sagemaker_execution_role.json

  tags = var.tags
}

resource "aws_iam_role_policy" "s3_access" {
  name = "${local.environment}-sagemaker-s3-access"
  role = aws_iam_role.sagemaker_execution_role.id

  policy = data.aws_iam_policy_document.sagemaker_s3_access.json
}

resource "aws_sagemaker_notebook_instance" "this" {
  name          = local.environment
  role_arn      = aws_iam_role.sagemaker_execution_role.arn
  instance_type = var.sagemaker_instance_type

  tags = var.tags
}