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

  validation {
    condition     = alltrue([for ns in var.peer_apex_name_servers : can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", ns))])
    error_message = "Each peer apex name server must be a valid FQDN (e.g., ns-1.example.com)."
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

variable "stg_peer_apex_name_servers" {
  description = "Peer authoritative name servers to mirror into the staging subdomain apex NS RRset."
  type        = list(string)

  validation {
    condition     = length(var.stg_peer_apex_name_servers) >= 1 && length(var.stg_peer_apex_name_servers) <= 3
    error_message = "Staging peer apex name servers must contain between 1 and 3 entries."
  }

  validation {
    condition     = length(distinct(var.stg_peer_apex_name_servers)) == length(var.stg_peer_apex_name_servers)
    error_message = "Staging peer apex name servers must not contain duplicates."
  }

  validation {
    condition     = alltrue([for ns in var.stg_peer_apex_name_servers : can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", ns))])
    error_message = "Each staging peer apex name server must be a valid FQDN (e.g., ns-1.example.com)."
  }
}

variable "prd_domain_name" {
  description = "Production subdomain name for NS delegation."
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

variable "prd_ns_name_servers" {
  description = "Name servers for production subdomain NS delegation."
  type        = list(string)

  validation {
    condition     = length(var.prd_ns_name_servers) >= 2 && length(var.prd_ns_name_servers) <= 6
    error_message = "Production NS name servers must contain between 2 and 6 entries."
  }

  validation {
    condition     = alltrue([for ns in var.prd_ns_name_servers : can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", ns))])
    error_message = "Each production NS entry must be a valid FQDN (e.g., ns-1.example.com)."
  }
}
