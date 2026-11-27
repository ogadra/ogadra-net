resource "google_dns_record_set" "tsujiura_ns" {
  managed_zone = data.google_dns_managed_zone.domain.name
  name         = data.google_dns_managed_zone.tsujiura.dns_name
  type         = "NS"
  ttl          = 10

  rrdatas = [for name_server in local.tsujiura_ns_rrset : "${name_server}."]
}
