provider "aws" {
  region = "us-east-2"
}



resource "aws_s3_bucket" "jcm_s3_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "My website hosting bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_website_configuration" "jcm_s3_website_config" {

  bucket = aws_s3_bucket.jcm_s3_bucket.id

  index_document {
    suffix = "index.html"
  }

#   error_document {
#     key = "error.html"
#   }

#   routing_rule {
#     condition {
#       key_prefix_equals = "docs/"
#     }
#     redirect {
#       replace_key_prefix_with = "documents/"
#     }
#   }
}


resource "aws_s3_bucket_public_access_block" "jcm_s3_bucket_public_access_allow" {
  bucket = aws_s3_bucket.jcm_s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
#   bucket = aws_s3_bucket.example.id
#   policy = data.aws_iam_policy_document.allow_access_from_another_account.json
# }

# data "aws_iam_policy_document" "allow_access_from_another_account" {
#   statement {
#     principals {
#       type        = "AWS"
#       identifiers = ["123456789012"]
#     }

#     actions = [
#       "s3:GetObject",
#       "s3:ListBucket",
#     ]

#     resources = [
#       aws_s3_bucket.example.arn,
#       "${aws_s3_bucket.example.arn}/*",
#     ]
#   }
# }

resource "aws_s3_bucket_policy" "jcm_allow_public_access" {
  bucket = aws_s3_bucket.jcm_s3_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.jcm_s3_bucket_public_access_allow]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.jcm_s3_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.jcm_s3_bucket.id
  key          = "index.html"
  content      = "<h1>Hello Claris! how was your day.</h1>"
  content_type = "text/html"

  
}