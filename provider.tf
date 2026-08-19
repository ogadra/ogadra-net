terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "aws" {
  alias   = "prd"
  region  = "us-east-1"
  profile = "prd"
}

provider "google" {
  alias   = "prd"
  project = var.google_cloud_project
}
