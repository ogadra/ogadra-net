terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
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
