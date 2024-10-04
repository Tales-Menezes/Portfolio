output "data-bucket-arn" {
  value = "Bucket ARN: ${aws_s3_bucket.website_bucket.arn}"
}

output "data-bucket-domain-name" {
  value = "Domain: www.${aws_s3_bucket.website_bucket.bucket_domain_name}"
}

output "data-bucket-region" {
  value = "The ${aws_s3_bucket.website_bucket.id} bucket is located in ${aws_s3_bucket.website_bucket.region}."
}