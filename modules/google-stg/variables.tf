variable "domain_name" {
  description = "Domain name for the managed zone."
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

variable "acm_validation_records" {
  description = "ACM DNS validation records for this zone."
  type = map(object({
    name   = string
    type   = string
    rrdata = string
  }))
}
