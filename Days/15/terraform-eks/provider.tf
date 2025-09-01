terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configuración de backend remoto (opcional pero recomendado)
  backend "s3" {
    bucket         = "terraform-state-eks"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-eks"
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region

  # Configuración opcional para asumir roles
  assume_role_with_web_identity {
    web_identity_token_file = var.web_identity_token_file
    role_arn                = var.role_arn
  }

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "30-Days-Of-Kubernetes"
      ManagedBy   = "Terraform"
    }
  }
}

# Proveedor para Helm (opcional)
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]
    }
  }
}

# Proveedor para Kubernetes (opcional)
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}