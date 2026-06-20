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

variable "domain_contact" {
  description = "Domain registration contact. Use an ISO 3166-2 prefecture code for state in Japanese addresses (e.g., JP-13)."
  type = object({
    contact_type   = string
    first_name     = string
    last_name      = string
    address_line_1 = string
    address_line_2 = optional(string)
    city           = string
    state          = string
    country_code   = string
    zip_code       = string
    phone_number   = string
    email          = string
  })
  sensitive = true

  validation {
    condition     = var.domain_contact.country_code != "JP" || contains([for code in range(1, 48) : format("JP-%02d", code)], var.domain_contact.state)
    error_message = "When domain_contact.country_code is JP, domain_contact.state must be an ISO 3166-2 Japanese prefecture code such as JP-13, not a prefecture name."
  }
}
