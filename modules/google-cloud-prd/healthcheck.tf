# A routing policy carries a single health check definition that is applied to
# every endpoint it references, so one probe covers both the AWS and the Google
# Cloud apex answers. host pins the SNI and Host header to real apex traffic.
resource "google_compute_health_check" "bunshin_apex" {
  name           = "${local.prd_zone_name}-apex"
  description    = "Gates the ${var.prd_domain_name} apex weighted answers."
  source_regions = local.prd_health_check_source_regions

  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 1
  unhealthy_threshold = 1

  https_health_check {
    port         = 443
    request_path = var.prd_health_check_path
    host         = var.prd_domain_name
  }
}
