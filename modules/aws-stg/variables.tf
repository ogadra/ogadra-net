variable "domain_name" {
  description = "Domain name for the hosted zone."
  type        = string

  validation {
    condition     = length(var.domain_name) > 0 && length(var.domain_name) <= 253
    error_message = "Domain name must be between 1 and 253 characters."
  }

  validation {
    condition     = can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}$", var.domain_name))
    error_message = "Domain name must be a valid FQDN (e.g., demo.example.com)."
  }
}

variable "peer_apex_name_servers" {
  description = "Peer authoritative name servers to mirror into this zone's apex NS RRset."
  type        = list(string)

  validation {
    condition     = length(var.peer_apex_name_servers) >= 1 && length(var.peer_apex_name_servers) <= 3
    error_message = "Peer apex name servers must contain between 1 and 3 entries."
  }

  validation {
    condition     = length(distinct(var.peer_apex_name_servers)) == length(var.peer_apex_name_servers)
    error_message = "Peer apex name servers must not contain duplicates."
  }
}

variable "stg_google_cloud_records" {
  description = "DNS records advertised in this zone (apex A/AAAA plus ACME DNS-01 challenge CNAMEs)."
  type = object({
    a_record    = string
    aaaa_record = string
    acme_cnames = map(object({
      name = string
      data = string
    }))
  })
}

variable "stg_aws_records" {
  description = "DNS records advertised in this zone from the AWS deployment (Route53 alias targets and ACM DNS validation CNAMEs)."
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
}

variable "stg_weights" {
  description = "Relative DNS answer weights for the staging apex weighted records."
  type = object({
    aws          = number
    google_cloud = number
  })
}

variable "stg_health_check_path" {
  description = "HTTPS resource path probed by health checks gating the apex weighted answers."
  type        = string

  validation {
    condition     = startswith(var.stg_health_check_path, "/")
    error_message = "Health check path must start with a slash."
  }
}
