output "state_bucket_name" {
  description = "Terraform remote state S3 bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "Terraform remote state S3 bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}