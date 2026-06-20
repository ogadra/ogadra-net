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
  alias   = "global"
  region  = "us-east-1"
  profile = "stg"
}

provider "aws" {
  alias   = "apne1"
  region  = "ap-northeast-1"
  profile = "stg"
}

provider "aws" {
  alias   = "apne3"
  region  = "ap-northeast-3"
  profile = "stg"
}
