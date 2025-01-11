# Provider Configuration
provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
}

# S3 Bucket for Static Website
resource "aws_s3_bucket" "static_website_bucket" {
  bucket = "karan-static-website" # Replace with your last name

  # Tags
  tags = {
    Name        = "StaticWebsiteBucket"
    Environment = "Dev"
  }
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.static_website_bucket.id
  block_public_policy     = false
  block_public_acls       = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Website Configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.static_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Bucket Policy for Public Read-Only Access
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_website_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}

# Versioning Configuration for Static Website Bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.static_website_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Default Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.static_website_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle Policy for Cost Optimization
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_policy" {
  bucket = aws_s3_bucket.static_website_bucket.id

  rule {
    id     = "MoveToIA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

# Replication Target Bucket
resource "aws_s3_bucket" "replication_bucket" {
  bucket = "karan-replication-bucket" # Replace with your last name

  # Tags
  tags = {
    Name        = "ReplicationBucket"
    Environment = "Dev"
  }
}

# Versioning for Replication Bucket
resource "aws_s3_bucket_versioning" "replication_versioning" {
  bucket = aws_s3_bucket.replication_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Replication Configuration
resource "aws_s3_bucket_replication_configuration" "replication_config" {
  bucket = aws_s3_bucket.static_website_bucket.id

  role = aws_iam_role.replication_role.arn

  rule {
    id     = "ReplicationRule"
    status = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = aws_s3_bucket.replication_bucket.arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Disabled" # Set to "Disabled" or "Enabled" depending on your requirements
    }
  }

  depends_on = [aws_s3_bucket_versioning.replication_versioning]
}


# IAM Role for Replication
resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "replication_policy" {
  role   = aws_iam_role.replication_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        Resource = aws_s3_bucket.static_website_bucket.arn
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = "${aws_s3_bucket.static_website_bucket.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.replication_bucket.arn}/*"
      }
    ]
  })
}
