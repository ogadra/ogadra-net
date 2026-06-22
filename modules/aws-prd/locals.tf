locals {
  bunshin_domain_name = "bunshin.${var.domain_name}"

  tags = {
    ManagedBy  = "Terraform"
    Repository = "ogadra-net"
  }
}
