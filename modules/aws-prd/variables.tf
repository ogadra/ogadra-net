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

variable "stg_ns_name_servers" {
  description = "Name servers for staging subdomain NS delegation."
  type        = list(string)
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
