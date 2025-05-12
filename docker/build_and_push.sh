#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

########################################
# Configuration (edit as needed)
AWS_ACCOUNT="704855531002"
PROJECT="eks_cobol"
AWS_REGION="us-east-1"
########################################

# Authenticate Docker to ECR
echo "Logging in to ECR (${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com)..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Iterate over each subdirectory
for dir in */; do
  # Skip if not a directory
  [[ -d "$dir" ]] || continue

  repo="${dir%/}"
  ecr_repo="${PROJECT}/${repo}"
  image_uri="${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ecr_repo}:0"

  echo
  echo "========================================"
  echo "Building & pushing '${repo}' → '${image_uri}'"
  echo "========================================"

  # Build, tag, and push
  docker buildx build \
    --platform linux/amd64 \
    --tag "${image_uri}" \
    --push \
    "${dir}"

  echo
  echo "========================================"
  echo "Pushed ${dir}' → '${image_uri}'"
  echo "========================================"
done

echo
echo "✅ All images built and pushed successfully."
