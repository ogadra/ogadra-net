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

variable "tsujiura_project_id" {
  description = "Google Cloud project holding the Tsujiura Cloud DNS zone, so its query logs land in that project."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.tsujiura_project_id))
    error_message = "tsujiura_project_id must be a valid Google Cloud project ID."
  }
}

variable "tsujiura_terraform_member" {
  description = "IAM member Terraform runs as, granted DNS administration on the Tsujiura project."
  type        = string

  validation {
    condition     = can(regex("^(user|serviceAccount):.+@.+$", var.tsujiura_terraform_member))
    error_message = "tsujiura_terraform_member must be an IAM member such as user:someone@example.com."
  }
}

variable "tsujiura_validation_cnames" {
  description = "ACM and Google-managed certificate DNS validation CNAMEs served from both Tsujiura zones."
  type = map(object({
    name = string
    data = string
  }))

  validation {
    condition = alltrue([
      for cname in values(var.tsujiura_validation_cnames) :
      can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.name))
      && can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.data))
    ])
    error_message = "Each tsujiura_validation_cnames entry must have a valid FQDN for name and data."
  }
}
