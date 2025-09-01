terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Backend para estado remoto (opcional)
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "gke"
  }
}