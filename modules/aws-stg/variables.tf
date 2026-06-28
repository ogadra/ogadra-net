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

variable "peer_ns_name_servers" {
  description = "Name servers from the peer DNS provider for this zone."
  type        = list(string)

  validation {
    condition     = length(var.peer_ns_name_servers) >= 2
    error_message = "Peer NS name servers must contain at least 2 entries."
  }

  validation {
    condition     = alltrue([for ns in var.peer_ns_name_servers : can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", ns))])
    error_message = "Each peer NS entry must be a valid FQDN (e.g., ns-1.example.com)."
  }
}
