variable "stg_google_cloud_records" {
  description = "DNS records advertised for the staging subdomain apex and ACME DNS-01 challenge CNAMEs."
  type = object({
    a_record    = string
    aaaa_record = string
    acme_cnames = map(object({
      name = string
      data = string
    }))
  })

  validation {
    condition     = can(cidrhost("${var.stg_google_cloud_records.a_record}/32", 0))
    error_message = "stg_google_cloud_records.a_record must be a valid IPv4 dotted-quad."
  }

  validation {
    condition     = can(cidrhost("${var.stg_google_cloud_records.aaaa_record}/128", 0))
    error_message = "stg_google_cloud_records.aaaa_record must be a valid IPv6 literal."
  }

  validation {
    condition = alltrue([
      for cname in values(var.stg_google_cloud_records.acme_cnames) :
      can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.name))
      && can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.data))
    ])
    error_message = "Each stg_google_cloud_records.acme_cnames entry must have a valid FQDN for name and data."
  }
}

variable "stg_aws_records" {
  description = "DNS records advertised for the staging subdomain from the AWS deployment (Route53 alias targets and ACM DNS validation CNAMEs)."
  type = object({
    user_dns = object({
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
    condition = alltrue([
      for alias in values(var.stg_aws_records.user_dns.aliases) :
      can(regex("^(\\*\\.)?([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", alias.name))
      && can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", alias.target))
      && can(regex("^Z[A-Z0-9]+$", alias.zone_id))
    ])
    error_message = "Each stg_aws_records.user_dns.aliases entry must have a valid DNS name (leading wildcard allowed), a valid FQDN target, and a Route53 hosted zone ID."
  }

  validation {
    condition = alltrue([
      for cname in values(var.stg_aws_records.user_dns_acm_validation) :
      can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.name))
      && can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.data))
    ])
    error_message = "Each stg_aws_records.user_dns_acm_validation entry must have a valid FQDN for name and data."
  }
}

variable "stg_weights" {
  description = "Relative DNS answer weights for the staging apex, shared by Route53 weighted records and NS1 weighted shuffle."
  type = object({
    aws          = number
    google_cloud = number
  })

  validation {
    condition = alltrue([
      for weight in [var.stg_weights.aws, var.stg_weights.google_cloud] :
      floor(weight) == weight && weight >= 0 && weight <= 100
    ]) && var.stg_weights.aws + var.stg_weights.google_cloud > 0
    error_message = "stg_weights must be integers between 0 and 100, and their sum must be greater than 0."
  }
}

variable "prd_records" {
  description = "DNS records advertised for the production subdomain apex and ACME DNS-01 challenge CNAMEs."
  type = object({
    a_record    = string
    aaaa_record = string
    acme_cnames = map(object({
      name = string
      data = string
    }))
  })

  validation {
    condition     = can(cidrhost("${var.prd_records.a_record}/32", 0))
    error_message = "prd_records.a_record must be a valid IPv4 dotted-quad."
  }

  validation {
    condition     = can(cidrhost("${var.prd_records.aaaa_record}/128", 0))
    error_message = "prd_records.aaaa_record must be a valid IPv6 literal."
  }

  validation {
    condition = alltrue([
      for cname in values(var.prd_records.acme_cnames) :
      can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.name))
      && can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.data))
    ])
    error_message = "Each prd_records.acme_cnames entry must have a valid FQDN for name and data."
  }
}
