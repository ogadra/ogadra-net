resource "aws_route53domains_domain" "domain" {
  domain_name       = local.domain_name
  duration_in_years = 1
  auto_renew        = true
  transfer_lock     = true

  name_server = [
    {
      name     = "ns-1383.awsdns-44.org"
      glue_ips = []
    },
    {
      name     = "ns-1824.awsdns-36.co.uk"
      glue_ips = []
    },
    {
      name     = "ns-564.awsdns-06.net"
      glue_ips = []
    },
    {
      name     = "ns-430.awsdns-53.com"
      glue_ips = []
    },
  ]

  admin_privacy      = true
  billing_privacy    = true
  registrant_privacy = true
  tech_privacy       = true

  admin_contact {
    contact_type      = var.domain_contact.contact_type
    first_name        = var.domain_contact.first_name
    last_name         = var.domain_contact.last_name
    organization_name = null
    address_line_1    = var.domain_contact.address_line_1
    address_line_2    = var.domain_contact.address_line_2
    city              = var.domain_contact.city
    state             = var.domain_contact.state
    country_code      = var.domain_contact.country_code
    zip_code          = var.domain_contact.zip_code
    phone_number      = var.domain_contact.phone_number
    email             = var.domain_contact.email
    fax               = null
  }

  registrant_contact {
    contact_type      = var.domain_contact.contact_type
    first_name        = var.domain_contact.first_name
    last_name         = var.domain_contact.last_name
    organization_name = null
    address_line_1    = var.domain_contact.address_line_1
    address_line_2    = var.domain_contact.address_line_2
    city              = var.domain_contact.city
    state             = var.domain_contact.state
    country_code      = var.domain_contact.country_code
    zip_code          = var.domain_contact.zip_code
    phone_number      = var.domain_contact.phone_number
    email             = var.domain_contact.email
    fax               = null
  }

  tech_contact {
    contact_type      = var.domain_contact.contact_type
    first_name        = var.domain_contact.first_name
    last_name         = var.domain_contact.last_name
    organization_name = null
    address_line_1    = var.domain_contact.address_line_1
    address_line_2    = var.domain_contact.address_line_2
    city              = var.domain_contact.city
    state             = var.domain_contact.state
    country_code      = var.domain_contact.country_code
    zip_code          = var.domain_contact.zip_code
    phone_number      = var.domain_contact.phone_number
    email             = var.domain_contact.email
    fax               = null
  }

  tags = {
    ManagedBy  = "Terraform"
    Repository = "ogadra-net"
  }

  lifecycle {
    prevent_destroy = true
  }
}
