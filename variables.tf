variable "stg_ipv4_address" {
  description = "IPv4 address advertised for the staging subdomain apex."
  type        = string

  validation {
    condition     = can(cidrhost("${var.stg_ipv4_address}/32", 0))
    error_message = "IPv4 address must be a valid dotted-quad."
  }
}

variable "stg_ipv6_address" {
  description = "IPv6 address advertised for the staging subdomain apex."
  type        = string

  validation {
    condition     = can(cidrhost("${var.stg_ipv6_address}/128", 0))
    error_message = "IPv6 address must be a valid IPv6 literal."
  }
}
