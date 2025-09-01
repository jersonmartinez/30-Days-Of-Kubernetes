# Configuración de AWS Config para EKS
# Este archivo configura AWS Config para monitorear cambios en recursos EKS

# CloudTrail para auditoría
resource "aws_cloudtrail" "eks_trail" {
  name                          = "${var.cluster_name}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}/*"]
    }

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  tags = {
    Name        = "${var.cluster_name}-cloudtrail"
    Environment = var.environment
  }
}

# Bucket S3 para CloudTrail
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "${var.cluster_name}-cloudtrail-${random_string.suffix.result}"

  tags = {
    Name        = "${var.cluster_name}-cloudtrail"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail.json
}

data "aws_iam_policy_document" "cloudtrail" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/cloudtrail/AWSLogs/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

# AWS Config
resource "aws_config_configuration_recorder" "eks" {
  name     = "${var.cluster_name}-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "eks" {
  name           = "${var.cluster_name}-config-delivery"
  s3_bucket_name = aws_s3_bucket.config.id
  s3_key_prefix  = "config"
  sns_topic_arn  = aws_sns_topic.config.arn

  snapshot_delivery_properties {
    delivery_frequency = "Six_Hours"
  }
}

resource "aws_config_configuration_recorder_status" "eks" {
  name       = aws_config_configuration_recorder.eks.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.eks]
}

# Bucket S3 para AWS Config
resource "aws_s3_bucket" "config" {
  bucket = "${var.cluster_name}-config-${random_string.suffix.result}"

  tags = {
    Name        = "${var.cluster_name}-config"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# SNS Topic para notificaciones de Config
resource "aws_sns_topic" "config" {
  name = "${var.cluster_name}-config-notifications"

  tags = {
    Name        = "${var.cluster_name}-config-sns"
    Environment = var.environment
  }
}

# IAM Role para AWS Config
resource "aws_iam_role" "config" {
  name = "${var.cluster_name}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-config-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

# Reglas de AWS Config específicas para EKS
resource "aws_config_config_rule" "eks_encrypted_volumes" {
  name = "${var.cluster_name}-eks-encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Volume"]
  }

  tags = {
    Name        = "${var.cluster_name}-encrypted-volumes-rule"
    Environment = var.environment
  }
}

resource "aws_config_config_rule" "eks_security_groups" {
  name = "${var.cluster_name}-eks-security-groups"

  source {
    owner             = "AWS"
    source_identifier = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }

  tags = {
    Name        = "${var.cluster_name}-security-groups-rule"
    Environment = var.environment
  }
}

# Random string para nombres únicos
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}