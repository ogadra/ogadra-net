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

variable "stg_domain_name" {
  description = "Staging subdomain name for NS delegation."
  type        = string

  validation {
    condition     = length(var.stg_domain_name) > 0 && length(var.stg_domain_name) <= 253
    error_message = "Staging domain name must be between 1 and 253 characters."
  }

  validation {
    condition     = can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}$", var.stg_domain_name))
    error_message = "Staging domain name must be a valid FQDN (e.g., demo.example.com)."
  }
}

variable "stg_apex_ns_rrset" {
  description = "Combined staging subdomain apex NS RRset (own aws-stg + peer ns1) written into the parent NS delegation."
  type        = list(string)

  validation {
    condition     = length(var.stg_apex_ns_rrset) >= 2 && length(var.stg_apex_ns_rrset) <= 6
    error_message = "Staging apex NS RRset must contain between 2 and 6 entries."
  }

  validation {
    condition     = length(distinct(var.stg_apex_ns_rrset)) == length(var.stg_apex_ns_rrset)
    error_message = "Staging apex NS RRset must not contain duplicates between own and peer authoritatives."
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
  description = "Combined production subdomain apex NS RRset (own aws-prd + peer ns1) written into the parent NS delegation."
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

variable "prd_peer_apex_name_servers" {
  description = "Peer authoritative name servers to mirror into the production subdomain apex NS RRset."
  type        = list(string)

  validation {
    condition     = length(var.prd_peer_apex_name_servers) >= 1 && length(var.prd_peer_apex_name_servers) <= 3
    error_message = "Production peer apex name servers must contain between 1 and 3 entries."
  }

  validation {
    condition     = length(distinct(var.prd_peer_apex_name_servers)) == length(var.prd_peer_apex_name_servers)
    error_message = "Production peer apex name servers must not contain duplicates."
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
  description = "DNS records advertised in the production zone from the AWS deployment (Route53 alias targets and ACM DNS validation CNAMEs)."
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
