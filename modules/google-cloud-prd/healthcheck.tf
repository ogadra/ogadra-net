# The external endpoint HTTPS prober has a TLS bug (OPENSSL_internal error) that
# makes every endpoint fail the handshake, leaving all targets UNHEALTHY and
# triggering fail-open — i.e. no gating at all.
#
# Falling back to TCP:443 loses application-level checks (503 from nginx looks
# healthy at the TCP layer) but at least detects a network-level outage where
# the Global Accelerator or GLB stops accepting connections. Route53 health
# checks still gate on HTTP 2xx, so the AWS authoritative catches app failures.
resource "google_compute_health_check" "bunshin_apex" {
  name           = "${local.prd_zone_name}-apex"
  description    = "Gates the ${var.prd_domain_name} apex weighted answers."
  source_regions = local.prd_health_check_source_regions

  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 1
  unhealthy_threshold = 1

  tcp_health_check {
    port = 443
  }

  log_config {
    enable = true
  }
}
