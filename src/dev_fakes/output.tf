output "bucket" {
    value = {
    bucket_name = aws_s3_bucket.fake_docs.arn
    bucket_access_policy = aws_iam_policy.dev_gateway_access.arn
  }
}
