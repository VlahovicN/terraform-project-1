output "bucket_arn" {
  value = aws_s3_bucket.html_backup.arn
}

output "bucket_arn_with_wildcard" {
  value = "${aws_s3_bucket.html_backup.arn}/*"
}