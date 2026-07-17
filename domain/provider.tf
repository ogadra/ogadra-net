terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    ns1 = {
      source  = "ns1-terraform/ns1"
      version = "~> 2.9"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "prd"
}

provider "ns1" {}
