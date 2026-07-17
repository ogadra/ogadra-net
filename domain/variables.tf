variable "domain_contact" {
  description = "Domain registrant contact. Use ISO 3166-2 codes for state (e.g. JP-13)."
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
    error_message = "state must be an ISO 3166-2 prefecture code (e.g. JP-13), not a prefecture name."
  }
}
