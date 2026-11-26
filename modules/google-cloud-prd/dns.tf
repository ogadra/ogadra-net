#trivy:ignore:AVD-GCP-0013
resource "google_dns_managed_zone" "domain" {
  #checkov:skip=CKV_GCP_16:Signing here alone would make resolvers reject the answers of the unsigned peer Route53 zone
  name        = local.zone_name
  dns_name    = "${var.domain_name}."
  description = "Apex zone served alongside Route53 for ${var.domain_name}."
  visibility  = "public"
  labels      = local.labels

  lifecycle {
    postcondition {
      condition     = length(self.name_servers) >= 3
      error_message = "Cloud DNS managed zone must expose at least 3 name servers for apex mirror."
    }
  }
}

resource "google_dns_record_set" "domain_ns" {
  managed_zone = google_dns_managed_zone.domain.name
  name         = google_dns_managed_zone.domain.dns_name
  type         = "NS"
  ttl          = 10

  rrdatas = [for name_server in var.apex_ns_rrset : "${name_server}."]
}

#trivy:ignore:AVD-GCP-0013
resource "google_dns_managed_zone" "bunshin" {
  #checkov:skip=CKV_GCP_16:Signing would cap each health-checked policy item at one address and break the multi-address AWS apex answer
  name        = local.prd_zone_name
  dns_name    = "${var.prd_domain_name}."
  description = "Production subdomain zone served alongside Route53 for ${var.prd_domain_name}."
  visibility  = "public"
  labels      = local.labels

  lifecycle {
    postcondition {
      condition     = length(self.name_servers) >= 3
      error_message = "Cloud DNS production zone must expose at least 3 name servers for apex mirror."
    }
  }
}

resource "google_dns_record_set" "bunshin_ns" {
  managed_zone = google_dns_managed_zone.domain.name
  name         = google_dns_managed_zone.bunshin.dns_name
  type         = "NS"
  ttl          = 10

  rrdatas = [for name_server in var.prd_apex_ns_rrset : "${name_server}."]
}

resource "google_dns_record_set" "bunshin_apex_ns" {
  managed_zone = google_dns_managed_zone.bunshin.name
  name         = google_dns_managed_zone.bunshin.dns_name
  type         = "NS"
  ttl          = 10

  rrdatas = [for name_server in var.prd_apex_ns_rrset : "${name_server}."]
}

resource "google_dns_record_set" "bunshin_apex_a" {
  managed_zone = google_dns_managed_zone.bunshin.name
  name         = google_dns_managed_zone.bunshin.dns_name
  type         = "A"
  ttl          = 10

  routing_policy {
    health_check = google_compute_health_check.bunshin_apex.id

    wrr {
      weight = var.prd_weights.aws

      health_checked_targets {
        external_endpoints = local.prd_aws_apex_a_records
      }
    }

    wrr {
      weight = var.prd_weights.google_cloud

      health_checked_targets {
        external_endpoints = [var.prd_google_cloud_records.a_record]
      }
    }
  }
}

# The AWS addresses are withheld from this answer: health checks on external
# endpoints are not gating the apex A record, so adding a second target here
# would send IPv6 clients to an endpoint Cloud DNS cannot fail away from.
resource "google_dns_record_set" "bunshin_apex_aaaa" {
  managed_zone = google_dns_managed_zone.bunshin.name
  name         = google_dns_managed_zone.bunshin.dns_name
  type         = "AAAA"
  ttl          = 10

  routing_policy {
    health_check = google_compute_health_check.bunshin_apex.id

    wrr {
      weight = var.prd_weights.google_cloud

      health_checked_targets {
        external_endpoints = [var.prd_google_cloud_records.aaaa_record]
      }
    }
  }
}

resource "google_dns_record_set" "bunshin_user_dns_a" {
  for_each = local.prd_aws_other_addresses

  managed_zone = google_dns_managed_zone.bunshin.name
  name         = "${trimsuffix(each.value.name, ".")}."
  type         = "A"
  ttl          = 10

  rrdatas = each.value.a_records
}

resource "google_dns_record_set" "bunshin_user_dns_aaaa" {
  for_each = {
    for key, address in local.prd_aws_other_addresses :
    key => address if length(coalesce(address.aaaa_records, [])) > 0
  }

  managed_zone = google_dns_managed_zone.bunshin.name
  name         = "${trimsuffix(each.value.name, ".")}."
  type         = "AAAA"
  ttl          = 10

  rrdatas = each.value.aaaa_records
}

# Cloud DNS has no ALIAS type, so these names answer with a CNAME while Route53
# flattens the same alias to A records. CloudFront has no static addresses to
# publish instead, and the CNAME lands on the same distribution. Variable
# validation keeps the apex out of this map, where a CNAME would be illegal.
resource "google_dns_record_set" "bunshin_user_dns_alias" {
  for_each = var.prd_aws_records.user_dns.aliases

  managed_zone = google_dns_managed_zone.bunshin.name
  name         = "${trimsuffix(each.value.name, ".")}."
  type         = "CNAME"
  ttl          = 10

  rrdatas = ["${trimsuffix(each.value.target, ".")}."]
}

resource "google_dns_record_set" "bunshin_google_cloud_a" {
  managed_zone = google_dns_managed_zone.bunshin.name
  name         = "google-cloud.${google_dns_managed_zone.bunshin.dns_name}"
  type         = "A"
  ttl          = 10

  rrdatas = [var.prd_google_cloud_records.a_record]
}

resource "google_dns_record_set" "bunshin_google_cloud_aaaa" {
  managed_zone = google_dns_managed_zone.bunshin.name
  name         = "google-cloud.${google_dns_managed_zone.bunshin.dns_name}"
  type         = "AAAA"
  ttl          = 10

  rrdatas = [var.prd_google_cloud_records.aaaa_record]
}

resource "google_dns_record_set" "bunshin_acme_challenge" {
  for_each = var.prd_google_cloud_records.acme_cnames

  managed_zone = google_dns_managed_zone.bunshin.name
  name         = "${trimsuffix(each.value.name, ".")}."
  type         = "CNAME"
  ttl          = 60

  rrdatas = ["${trimsuffix(each.value.data, ".")}."]
}

resource "google_dns_record_set" "bunshin_user_dns_acm_validation" {
  for_each = var.prd_aws_records.user_dns_acm_validation

  managed_zone = google_dns_managed_zone.bunshin.name
  name         = "${trimsuffix(each.value.name, ".")}."
  type         = "CNAME"
  ttl          = 60

  rrdatas = ["${trimsuffix(each.value.data, ".")}."]
}

resource "google_dns_record_set" "bunshin_region_a" {
  for_each = local.prd_regions

  managed_zone = google_dns_managed_zone.bunshin.name
  name         = "*.${each.value}.${google_dns_managed_zone.bunshin.dns_name}"
  type         = "A"
  ttl          = 10

  rrdatas = [var.prd_google_cloud_records.a_record]
}

resource "google_dns_record_set" "bunshin_region_aaaa" {
  for_each = local.prd_regions

  managed_zone = google_dns_managed_zone.bunshin.name
  name         = "*.${each.value}.${google_dns_managed_zone.bunshin.dns_name}"
  type         = "AAAA"
  ttl          = 10

  rrdatas = [var.prd_google_cloud_records.aaaa_record]
}
