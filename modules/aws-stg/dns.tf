resource "aws_route53_record" "apex_ns" {
  allow_overwrite = true
  zone_id         = aws_route53_zone.zone.zone_id
  name            = var.domain_name
  type            = "NS"
  ttl             = 10

  records = local.apex_ns_name_servers

  lifecycle {
    precondition {
      condition     = length(distinct(local.apex_ns_name_servers)) == length(local.apex_ns_name_servers)
      error_message = "Apex NS RRset must not contain duplicate name servers between own and peer authoritatives."
    }
  }
}

resource "aws_route53_record" "apex_a_google_cloud" {
  #checkov:skip=CKV2_AWS_23:Points to an external IP, not an AWS resource
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 10

  set_identifier = "google-cloud"
  weighted_routing_policy {
    weight = var.stg_weights.google_cloud
  }
  health_check_id = local.stg_aws_apex_alias != null ? aws_route53_health_check.apex_google_cloud[0].id : null

  records = [var.stg_google_cloud_records.a_record]
}

resource "aws_route53_record" "apex_aaaa_google_cloud" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "AAAA"
  ttl     = 10

  set_identifier = "google-cloud"
  weighted_routing_policy {
    weight = var.stg_weights.google_cloud
  }
  health_check_id = local.stg_aws_apex_alias != null ? aws_route53_health_check.apex_google_cloud[0].id : null

  records = [var.stg_google_cloud_records.aaaa_record]
}

moved {
  from = aws_route53_record.apex_a
  to   = aws_route53_record.apex_a_google_cloud
}

moved {
  from = aws_route53_record.apex_aaaa
  to   = aws_route53_record.apex_aaaa_google_cloud
}

resource "aws_route53_record" "apex_a_aws" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "aws"
  weighted_routing_policy {
    weight = var.stg_weights.aws
  }
  health_check_id = aws_route53_health_check.apex_aws[0].id

  alias {
    name                   = local.stg_aws_apex_alias.target
    zone_id                = local.stg_aws_apex_alias.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "apex_aaaa_aws" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "AAAA"

  set_identifier = "aws"
  weighted_routing_policy {
    weight = var.stg_weights.aws
  }
  health_check_id = aws_route53_health_check.apex_aws[0].id

  alias {
    name                   = local.stg_aws_apex_alias.target
    zone_id                = local.stg_aws_apex_alias.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "user_dns_alias_a" {
  #checkov:skip=CKV2_AWS_23:Alias targets are AWS resources managed in a separate repository
  for_each = local.stg_aws_other_aliases

  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = "A"

  alias {
    name                   = each.value.target
    zone_id                = each.value.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "user_dns_alias_aaaa" {
  for_each = local.stg_aws_other_aliases

  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = "AAAA"

  alias {
    name                   = each.value.target
    zone_id                = each.value.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "google_cloud_a" {
  #checkov:skip=CKV2_AWS_23:Points to an external IP, not an AWS resource
  zone_id = aws_route53_zone.zone.zone_id
  name    = "google-cloud.${var.domain_name}"
  type    = "A"
  ttl     = 10

  records = [var.stg_google_cloud_records.a_record]
}

resource "aws_route53_record" "google_cloud_aaaa" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "google-cloud.${var.domain_name}"
  type    = "AAAA"
  ttl     = 10

  records = [var.stg_google_cloud_records.aaaa_record]
}

resource "aws_route53_record" "acme_challenge" {
  for_each = var.stg_google_cloud_records.acme_cnames

  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = 60

  records = [each.value.data]
}

resource "aws_route53_record" "user_dns_acm_validation" {
  for_each = var.stg_aws_records.user_dns_acm_validation

  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = 60

  records = [each.value.data]
}

resource "aws_route53_record" "stg_region_a" {
  #checkov:skip=CKV2_AWS_23:Points to an external IP, not an AWS resource
  for_each = local.stg_regions

  zone_id = aws_route53_zone.zone.zone_id
  name    = "*.${each.value}.${var.domain_name}"
  type    = "A"
  ttl     = 10

  records = [var.stg_google_cloud_records.a_record]
}

resource "aws_route53_record" "stg_region_aaaa" {
  for_each = local.stg_regions

  zone_id = aws_route53_zone.zone.zone_id
  name    = "*.${each.value}.${var.domain_name}"
  type    = "AAAA"
  ttl     = 10

  records = [var.stg_google_cloud_records.aaaa_record]
}
