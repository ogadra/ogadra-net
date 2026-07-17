terraform {
  required_version = ">= 1.15.0"

  required_providers {
    ns1 = {
      source  = "ns1-terraform/ns1"
      version = "~> 2.9"
    }
  }
}
