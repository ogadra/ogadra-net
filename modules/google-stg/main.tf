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
