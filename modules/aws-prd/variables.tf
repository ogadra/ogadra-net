variable "domain_name" {
  description = "Domain name for DNS records."
  type        = string

  validation {
    condition     = length(var.domain_name) > 0 && length(var.domain_name) <= 253
    error_message = "Domain name must be between 1 and 253 characters."
  }

  validation {
    condition     = can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}$", var.domain_name))
    error_message = "Domain name must be a valid FQDN (e.g., example.com)."
  }
}

variable "apex_ns_rrset" {
  description = "Combined apex NS RRset (own aws-prd + peer google-cloud-prd) written into this zone's apex."
  type        = list(string)

  validation {
    condition     = length(var.apex_ns_rrset) >= 2 && length(var.apex_ns_rrset) <= 6
    error_message = "Apex NS RRset must contain between 2 and 6 entries."
  }

  validation {
    condition     = length(distinct(var.apex_ns_rrset)) == length(var.apex_ns_rrset)
    error_message = "Apex NS RRset must not contain duplicates between own and peer authoritatives."
  }
}

variable "prd_domain_name" {
  description = "Production subdomain name for the hosted zone."
  type        = string

  validation {
    condition     = length(var.prd_domain_name) > 0 && length(var.prd_domain_name) <= 253
    error_message = "Production domain name must be between 1 and 253 characters."
  }

  validation {
    condition     = can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}$", var.prd_domain_name))
    error_message = "Production domain name must be a valid FQDN (e.g., bunshin.example.com)."
  }
}

variable "prd_apex_ns_rrset" {
  description = "Combined production subdomain apex NS RRset (own aws-prd + peer google-cloud-prd) written into the parent NS delegation."
  type        = list(string)

  validation {
    condition     = length(var.prd_apex_ns_rrset) >= 2 && length(var.prd_apex_ns_rrset) <= 6
    error_message = "Production apex NS RRset must contain between 2 and 6 entries."
  }

  validation {
    condition     = length(distinct(var.prd_apex_ns_rrset)) == length(var.prd_apex_ns_rrset)
    error_message = "Production apex NS RRset must not contain duplicates between own and peer authoritatives."
  }
}

variable "prd_google_cloud_records" {
  description = "DNS records advertised in the production zone (apex A/AAAA plus ACME DNS-01 challenge CNAMEs)."
  type = object({
    a_record    = string
    aaaa_record = string
    acme_cnames = map(object({
      name = string
      data = string
    }))
  })
}

variable "prd_aws_records" {
  description = "DNS records advertised in the production zone from the AWS deployment (static IPv4 addresses, Route53 alias targets and ACM DNS validation CNAMEs)."
  type = object({
    user_dns = object({
      addresses = map(object({
        name         = string
        a_records    = list(string)
        aaaa_records = optional(list(string))
      }))
      aliases = map(object({
        name    = string
        target  = string
        zone_id = string
      }))
    })
    user_dns_acm_validation = map(object({
      name = string
      data = string
    }))
  })

  validation {
    condition = length([
      for address in values(var.prd_aws_records.user_dns.addresses) :
      address if trimsuffix(address.name, ".") == var.prd_domain_name
    ]) == 1
    error_message = "prd_aws_records.user_dns.addresses must contain exactly one entry whose name matches prd_domain_name (${var.prd_domain_name}); its addresses are the AWS apex answer competing with the Google Cloud GLB via weighted records."
  }

  validation {
    condition = length([
      for alias in values(var.prd_aws_records.user_dns.aliases) :
      alias if trimsuffix(alias.name, ".") == var.prd_domain_name
    ]) == 0
    error_message = "prd_aws_records.user_dns.aliases must not contain an entry whose name matches prd_domain_name (${var.prd_domain_name}); the apex is answered with the static IPv4 addresses instead."
  }
}

variable "prd_weights" {
  description = "Relative DNS answer weights for the production apex weighted records."
  type = object({
    aws          = number
    google_cloud = number
  })
}

variable "prd_health_check_path" {
  description = "HTTPS resource path probed by health checks gating the production apex weighted answers."
  type        = string

  validation {
    condition     = startswith(var.prd_health_check_path, "/")
    error_message = "Health check path must start with a slash."
  }
}
