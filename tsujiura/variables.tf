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

variable "tsujiura_frontend_addresses" {
  description = "IPv4 addresses of the Tsujiura frontends, served as the apex and wildcard A records from both zones."
  type = object({
    global_accelerator = list(string)
    google_cloud_lb    = string
  })

  validation {
    condition     = length(var.tsujiura_frontend_addresses.global_accelerator) == 2
    error_message = "tsujiura_frontend_addresses.global_accelerator must contain both static IPs of the Global Accelerator."
  }

  validation {
    condition = alltrue([
      for address in concat(var.tsujiura_frontend_addresses.global_accelerator, [var.tsujiura_frontend_addresses.google_cloud_lb]) :
      can(cidrhost("${address}/32", 0))
    ])
    error_message = "Each tsujiura_frontend_addresses entry must be a valid IPv4 dotted-quad."
  }
}

variable "tsujiura_validation_cnames" {
  description = "ACM and Google-managed certificate DNS validation CNAMEs served from both Tsujiura zones."
  type = map(object({
    name = string
    data = string
  }))

  validation {
    condition = alltrue([
      for cname in values(var.tsujiura_validation_cnames) :
      can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.name))
      && can(regex("^([a-zA-Z0-9_]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", cname.data))
    ])
    error_message = "Each tsujiura_validation_cnames entry must have a valid FQDN for name and data."
  }
}
