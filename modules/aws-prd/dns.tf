data "aws_route53_zone" "domain" {
  name         = var.domain_name
  private_zone = false

  lifecycle {
    postcondition {
      condition     = length(self.name_servers) >= 3
      error_message = "AWS Route53 hosted zone must expose at least 3 name servers for apex mirror."
    }
  }
}

resource "aws_route53_record" "domain_ns" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.domain.zone_id
  name            = var.domain_name
  type            = "NS"
  ttl             = 10

  records = var.apex_ns_rrset
}

resource "aws_route53_zone" "bunshin" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not required for this subdomain
  #checkov:skip=CKV2_AWS_39:DNS query logging is not required for this subdomain
  name = var.prd_domain_name

  tags = local.tags
}

resource "aws_route53_record" "bunshin_ns" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.prd_domain_name
  type    = "NS"
  ttl     = 10

  records = var.prd_apex_ns_rrset
}

resource "aws_route53_record" "bunshin_apex_ns" {
  allow_overwrite = true
  zone_id         = aws_route53_zone.bunshin.zone_id
  name            = var.prd_domain_name
  type            = "NS"
  ttl             = 10

  records = var.prd_apex_ns_rrset
}

resource "aws_route53_record" "bunshin_apex_a_google_cloud" {
  #checkov:skip=CKV2_AWS_23:Points to an external IP, not an AWS resource
  zone_id = aws_route53_zone.bunshin.zone_id
  name    = var.prd_domain_name
  type    = "A"
  ttl     = 10

  set_identifier = "google-cloud"
  weighted_routing_policy {
    weight = var.prd_weights.google_cloud
  }
  health_check_id = aws_route53_health_check.bunshin_apex_google_cloud.id

  records = [var.prd_google_cloud_records.a_record]
}

resource "aws_route53_record" "bunshin_apex_aaaa_google_cloud" {
  zone_id = aws_route53_zone.bunshin.zone_id
  name    = var.prd_domain_name
  type    = "AAAA"
  ttl     = 10

  set_identifier = "google-cloud"
  weighted_routing_policy {
    weight = var.prd_weights.google_cloud
  }
  health_check_id = aws_route53_health_check.bunshin_apex_google_cloud.id

  records = [var.prd_google_cloud_records.aaaa_record]
}

resource "aws_route53_record" "bunshin_apex_a_aws" {
  #checkov:skip=CKV2_AWS_23:Points to Global Accelerator static IPs managed in a separate repository
  zone_id = aws_route53_zone.bunshin.zone_id
  name    = var.prd_domain_name
  type    = "A"
  ttl     = 10

  set_identifier = "aws"
  weighted_routing_policy {
    weight = var.prd_weights.aws
  }
  health_check_id = aws_route53_health_check.bunshin_apex_aws_a.id

  records = local.prd_aws_apex_a_records
}

resource "aws_route53_record" "bunshin_apex_aaaa_aws" {
  count = length(local.prd_aws_apex_aaaa_records) > 0 ? 1 : 0

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = var.prd_domain_name
  type    = "AAAA"
  ttl     = 10

  set_identifier = "aws"
  weighted_routing_policy {
    weight = var.prd_weights.aws
  }
  health_check_id = aws_route53_health_check.bunshin_apex_aws_aaaa[0].id

  records = local.prd_aws_apex_aaaa_records
}

resource "aws_route53_record" "bunshin_user_dns_a" {
  #checkov:skip=CKV2_AWS_23:Points to Global Accelerator static IPs managed in a separate repository
  for_each = local.prd_aws_other_addresses

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = each.value.name
  type    = "A"
  ttl     = 10

  records = each.value.a_records
}

resource "aws_route53_record" "bunshin_user_dns_aaaa" {
  for_each = {
    for key, address in local.prd_aws_other_addresses :
    key => address if length(coalesce(address.aaaa_records, [])) > 0
  }

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = each.value.name
  type    = "AAAA"
  ttl     = 10

  records = each.value.aaaa_records
}

resource "aws_route53_record" "bunshin_user_dns_alias_a" {
  #checkov:skip=CKV2_AWS_23:Alias targets are AWS resources managed in a separate repository
  for_each = var.prd_aws_records.user_dns.aliases

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = each.value.name
  type    = "A"

  alias {
    name                   = each.value.target
    zone_id                = each.value.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "bunshin_user_dns_alias_aaaa" {
  for_each = var.prd_aws_records.user_dns.aliases

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = each.value.name
  type    = "AAAA"

  alias {
    name                   = each.value.target
    zone_id                = each.value.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "bunshin_google_cloud_a" {
  #checkov:skip=CKV2_AWS_23:Points to an external IP, not an AWS resource
  zone_id = aws_route53_zone.bunshin.zone_id
  name    = "google-cloud.${var.prd_domain_name}"
  type    = "A"
  ttl     = 10

  records = [var.prd_google_cloud_records.a_record]
}

resource "aws_route53_record" "bunshin_google_cloud_aaaa" {
  zone_id = aws_route53_zone.bunshin.zone_id
  name    = "google-cloud.${var.prd_domain_name}"
  type    = "AAAA"
  ttl     = 10

  records = [var.prd_google_cloud_records.aaaa_record]
}

resource "aws_route53_record" "bunshin_acme_challenge" {
  for_each = var.prd_google_cloud_records.acme_cnames

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = 60

  records = [each.value.data]
}

resource "aws_route53_record" "bunshin_user_dns_acm_validation" {
  for_each = var.prd_aws_records.user_dns_acm_validation

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = 60

  records = [each.value.data]
}

resource "aws_route53_record" "bunshin_region_a" {
  #checkov:skip=CKV2_AWS_23:Points to an external IP, not an AWS resource
  for_each = local.prd_regions

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = "*.${each.value}.${var.prd_domain_name}"
  type    = "A"
  ttl     = 10

  records = [var.prd_google_cloud_records.a_record]
}

resource "aws_route53_record" "bunshin_region_aaaa" {
  for_each = local.prd_regions

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = "*.${each.value}.${var.prd_domain_name}"
  type    = "AAAA"
  ttl     = 10

  records = [var.prd_google_cloud_records.aaaa_record]
}
