#trivy:ignore:AVD-GCP-0013
resource "google_dns_managed_zone" "tsujiura" {
  #checkov:skip=CKV_GCP_16:Signing here alone would make resolvers reject the answers of the unsigned peer Route53 zone
  project     = var.tsujiura_project_id
  name        = replace(local.tsujiura_domain_name, ".", "-")
  dns_name    = "${local.tsujiura_domain_name}."
  description = "Tsujiura subdomain zone served alongside Route53 for ${local.tsujiura_domain_name}."
  visibility  = "public"
  labels      = local.common_labels

  cloud_logging_config {
    enable_logging = true
  }

  depends_on = [google_project_iam_member.tsujiura_dns_admin]
}

resource "google_dns_record_set" "tsujiura_ns" {
  managed_zone = data.google_dns_managed_zone.domain.name
  name         = google_dns_managed_zone.tsujiura.dns_name
  type         = "NS"
  ttl          = 10

  rrdatas = [for name_server in local.tsujiura_apex_ns_rrset : "${name_server}."]
}

resource "google_dns_record_set" "tsujiura_apex_ns" {
  project      = var.tsujiura_project_id
  managed_zone = google_dns_managed_zone.tsujiura.name
  name         = google_dns_managed_zone.tsujiura.dns_name
  type         = "NS"
  ttl          = 10

  rrdatas = [for name_server in local.tsujiura_apex_ns_rrset : "${name_server}."]
}
