variable "google_prd_project_id" {
  description = "Google Cloud project ID for production DNS resources."
  type        = string
}

variable "impersonate_service_account" {
  description = "Service account ID for Google provider impersonation."
  type        = string
}
