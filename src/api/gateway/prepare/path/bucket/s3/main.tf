terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "kbaas"
}

resource "aws_s3_bucket" "docs" {
  bucket_prefix = "docs"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.docs.id
  key    = "test"
  source = "${path.module}/test.txt"
}

resource "aws_s3_bucket_public_access_block" "docs" {
  bucket = aws_s3_bucket.docs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "api_gateway_s3_list_policy" {
  name        = "APIGatewayS3ListObjectsPolicy"
  description = "Allows API Gateway to list objects and get location in the specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject"
        ],
        Resource = [
          aws_s3_bucket.docs.arn,
          "${aws_s3_bucket.docs.arn}/*",
        ],
      },
    ],
  })
}

output "bucket_name" {
  value = aws_s3_bucket.docs.id
}

output "policy_arn" {
  value = aws_iam_policy.api_gateway_s3_list_policy.arn
}
