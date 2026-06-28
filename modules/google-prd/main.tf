#trivy:ignore:AVD-GCP-0013
resource "google_dns_managed_zone" "zone" {
  #checkov:skip=CKV_GCP_16:DNSSEC is not required for this zone
  name     = replace(trimsuffix(var.domain_name, "."), ".", "-")
  dns_name = "${trimsuffix(var.domain_name, ".")}."

  deletion_policy = "PREVENT"

  labels = {
    managed_by = "terraform"
    repository = "ogadra-net"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "zone_ns" {
  managed_zone = google_dns_managed_zone.zone.name
  name         = google_dns_managed_zone.zone.dns_name
  type         = "NS"
  ttl          = 60
  rrdatas      = [for name_server in var.domain_ns_name_servers : "${trimsuffix(name_server, ".")}."]

  deletion_policy = "PREVENT"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "stg_ns" {
  managed_zone = google_dns_managed_zone.zone.name
  name         = "${trimsuffix(var.stg_domain_name, ".")}."
  type         = "NS"
  ttl          = 0
  rrdatas      = formatlist("%s.", var.stg_ns_name_servers)

  deletion_policy = "PREVENT"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "prd_ns" {
  managed_zone = google_dns_managed_zone.zone.name
  name         = "${trimsuffix(var.prd_domain_name, ".")}."
  type         = "NS"
  ttl          = 0
  rrdatas      = formatlist("%s.", var.prd_ns_name_servers)

  deletion_policy = "PREVENT"

  lifecycle {
    prevent_destroy = true
  }
}
