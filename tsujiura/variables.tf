variable "tsujiura_project_id" {
  description = "Google Cloud project holding the Tsujiura Cloud DNS zone, so its query logs land in that project."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.tsujiura_project_id))
    error_message = "tsujiura_project_id must be a valid Google Cloud project ID."
  }
}

variable "tsujiura_terraform_member" {
  description = "IAM member Terraform runs as, granted DNS administration on the Tsujiura project."
  type        = string

  validation {
    condition     = can(regex("^(user|serviceAccount):.+@.+$", var.tsujiura_terraform_member))
    error_message = "tsujiura_terraform_member must be an IAM member such as user:someone@example.com."
  }
}
