variable "prd_google_cloud_records" {
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
    condition     = can(cidrhost("${var.prd_google_cloud_records.a_record}/32", 0))
    error_message = "prd_google_cloud_records.a_record must be a valid IPv4 dotted-quad."
  }

  validation {
    condition     = can(cidrhost("${var.prd_google_cloud_records.aaaa_record}/128", 0))
    error_message = "prd_google_cloud_records.aaaa_record must be a valid IPv6 literal."
  }

  validation {
    condition = alltrue([
      for cname in values(var.prd_google_cloud_records.acme_cnames) :
      can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.name))
      && can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.data))
    ])
    error_message = "Each prd_google_cloud_records.acme_cnames entry must have a valid FQDN for name and data."
  }
}

variable "prd_aws_records" {
  description = "DNS records advertised for the production subdomain from the AWS deployment (static IPv4 addresses, Route53 alias targets and ACM DNS validation CNAMEs)."
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
    condition = alltrue([
      for address in values(var.prd_aws_records.user_dns.addresses) :
      can(regex("^(\\*\\.)?([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", address.name))
      && length(address.a_records) > 0
      && alltrue([for ip in address.a_records : can(cidrhost("${ip}/32", 0)) && !strcontains(ip, ":")])
      && alltrue([for ip in coalesce(address.aaaa_records, []) : can(cidrhost("${ip}/128", 0)) && strcontains(ip, ":")])
    ])
    error_message = "Each prd_aws_records.user_dns.addresses entry must have a valid DNS name (leading wildcard allowed), at least one IPv4 dotted-quad in a_records, and only IPv6 literals in aaaa_records."
  }

  validation {
    condition = alltrue([
      for alias in values(var.prd_aws_records.user_dns.aliases) :
      can(regex("^(\\*\\.)?([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", alias.name))
      && can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", alias.target))
      && can(regex("^Z[A-Z0-9]+$", alias.zone_id))
    ])
    error_message = "Each prd_aws_records.user_dns.aliases entry must have a valid DNS name (leading wildcard allowed), a valid FQDN target, and a Route53 hosted zone ID."
  }

  validation {
    condition = alltrue([
      for cname in values(var.prd_aws_records.user_dns_acm_validation) :
      can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.name))
      && can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.data))
    ])
    error_message = "Each prd_aws_records.user_dns_acm_validation entry must have a valid FQDN for name and data."
  }
}

variable "prd_weights" {
  description = "Relative DNS answer weights for the production apex, shared by Route53 weighted records and NS1 weighted shuffle."
  type = object({
    aws          = number
    google_cloud = number
  })

  validation {
    condition = alltrue([
      for weight in [var.prd_weights.aws, var.prd_weights.google_cloud] :
      floor(weight) == weight && weight >= 1 && weight <= 100
    ])
    error_message = "prd_weights must be integers between 1 and 100 (weight 0 would make NS1's weighted shuffle return an empty answer set once the other side is down)."
  }
}
