terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ── S3 Bucket ──────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "data_lake" {
  bucket        = "${var.bucket_prefix}-${var.student_name}"
  force_destroy = true

  tags = {
    Project     = "data-lake-workshop"
    Environment = "workshop"
  }
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket                  = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Estructura de carpetas (objetos vacíos como prefijos)
resource "aws_s3_object" "folders" {
  for_each = toset([
    "raw/sales/",
    "curated/sales/",
    "athena-results/",
  ])
  bucket  = aws_s3_bucket.data_lake.id
  key     = each.value
  content = ""
}

# ── IAM Role para Glue ─────────────────────────────────────────────────────────

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue" {
  name               = "AWSGlueServiceRole-DataLakeWorkshop"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json

  tags = {
    Project = "data-lake-workshop"
  }
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_s3" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "glue_cloudwatch" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# ── Glue Data Catalog ──────────────────────────────────────────────────────────

resource "aws_glue_catalog_database" "sales_db" {
  name        = "sales_db"
  description = "Base de datos del Data Lake - Workshop"
}
