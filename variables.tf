variable "google_prd_project_id" {
  description = "Google Cloud project ID for production DNS resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.google_prd_project_id))
    error_message = "Google Cloud project ID must be 6-30 chars: lowercase letters, digits, or hyphens; start with a letter and not end with a hyphen."
  }
}

variable "google_stg_project_id" {
  description = "Google Cloud project ID for staging DNS resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.google_stg_project_id))
    error_message = "Google Cloud project ID must be 6-30 chars: lowercase letters, digits, or hyphens; start with a letter and not end with a hyphen."
  }
}

variable "google_prd_impersonate_service_account" {
  description = "Service account ID for Google production provider impersonation."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.google_prd_impersonate_service_account))
    error_message = "Service account ID must be 6-30 chars: lowercase letters, digits, or hyphens; start with a letter and not end with a hyphen."
  }
}

variable "google_stg_impersonate_service_account" {
  description = "Service account ID for Google staging provider impersonation."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.google_stg_impersonate_service_account))
    error_message = "Service account ID must be 6-30 chars: lowercase letters, digits, or hyphens; start with a letter and not end with a hyphen."
  }
}
