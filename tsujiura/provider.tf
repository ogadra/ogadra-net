terraform {
  required_version = "= 1.17.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.74.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "= 8.12.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "prd"
}

provider "google" {}
