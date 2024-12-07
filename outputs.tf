output "bucket_name" {
  value = aws_s3_bucket.s3_bucket.bucket
}

output "instance_public_ip" {
  value = aws_instance.s3_service_instance.public_ip
}
