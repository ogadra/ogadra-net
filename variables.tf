variable "stg_records" {
  description = "DNS records advertised for the staging subdomain apex and ACME DNS-01 challenge CNAMEs."
  type = object({
    a_record    = string
    aaaa_record = string
    acme_cnames = map(object({
      name = string
      data = string
    }))
  })

  validation {
    condition     = can(cidrhost("${var.stg_records.a_record}/32", 0))
    error_message = "stg_records.a_record must be a valid IPv4 dotted-quad."
  }

  validation {
    condition     = can(cidrhost("${var.stg_records.aaaa_record}/128", 0))
    error_message = "stg_records.aaaa_record must be a valid IPv6 literal."
  }
}
