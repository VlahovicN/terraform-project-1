resource "aws_s3_bucket" "html_backup" {
  bucket = var.bucket_name
  force_destroy = true
  tags = {
    Name        = var.bucket_name
  }
}


resource "aws_s3_bucket_policy" "public_access_policy" {
  bucket = aws_s3_bucket.html_backup.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.html_backup.arn}/*",  # Allow access to all objects within the bucket
      },
    ],
  })
  depends_on = [ aws_s3_bucket_public_access_block.allow_public ]
}

resource "aws_s3_object" "add_html_file" {
  bucket = aws_s3_bucket.html_backup.id
  key = "backup/index.html"
  source = "/home/nikola/terraform-project-1/index.html"
  depends_on = [ aws_s3_bucket.html_backup ]
  content_type = "text/html"
}



resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.html_backup.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
