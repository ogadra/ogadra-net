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

  records = local.apex_ns_name_servers

  lifecycle {
    precondition {
      condition     = length(distinct(local.apex_ns_name_servers)) == length(local.apex_ns_name_servers)
      error_message = "Apex NS RRset must not contain duplicate name servers between own and peer authoritatives."
    }
  }
}

resource "aws_route53_record" "demo_ns" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.stg_domain_name
  type    = "NS"
  ttl     = 10

  records = var.stg_apex_ns_rrset
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

  records = local.bunshin_apex_ns_name_servers

  lifecycle {
    precondition {
      condition     = length(distinct(local.bunshin_apex_ns_name_servers)) == length(local.bunshin_apex_ns_name_servers)
      error_message = "Production apex NS RRset must not contain duplicate name servers between own and peer authoritatives."
    }
  }
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
  zone_id = aws_route53_zone.bunshin.zone_id
  name    = var.prd_domain_name
  type    = "A"

  set_identifier = "aws"
  weighted_routing_policy {
    weight = var.prd_weights.aws
  }
  health_check_id = aws_route53_health_check.bunshin_apex_aws.id

  alias {
    name                   = local.prd_aws_apex_alias.target
    zone_id                = local.prd_aws_apex_alias.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "bunshin_apex_aaaa_aws" {
  zone_id = aws_route53_zone.bunshin.zone_id
  name    = var.prd_domain_name
  type    = "AAAA"

  set_identifier = "aws"
  weighted_routing_policy {
    weight = var.prd_weights.aws
  }
  health_check_id = aws_route53_health_check.bunshin_apex_aws.id

  alias {
    name                   = local.prd_aws_apex_alias.target
    zone_id                = local.prd_aws_apex_alias.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "bunshin_user_dns_alias_a" {
  #checkov:skip=CKV2_AWS_23:Alias targets are AWS resources managed in a separate repository
  for_each = local.prd_aws_other_aliases

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
  for_each = local.prd_aws_other_aliases

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
