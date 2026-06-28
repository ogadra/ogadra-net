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

variable "google_prd_project_id" {
  description = "Google Cloud project ID for production DNS resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.google_prd_project_id))
    error_message = "Google Cloud project ID must be 6-30 chars: lowercase letters, digits, or hyphens; start with a letter and not end with a hyphen."
  }
}

variable "impersonate_service_account" {
  description = "Service account ID for Google provider impersonation."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.impersonate_service_account))
    error_message = "Service account ID must be 6-30 chars: lowercase letters, digits, or hyphens; start with a letter and not end with a hyphen."
  }
}
