terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 7.38.0"
    }
  }
}

provider "aws" {
  alias   = "prd"
  region  = "us-east-1"
  profile = "prd"
}

provider "aws" {
  alias   = "stg"
  region  = "us-east-1"
  profile = "stg"
}

provider "google" {
  alias   = "prd"
  project = var.google_prd_project_id

  impersonate_service_account = local.google_prd_impersonate_service_account
}
