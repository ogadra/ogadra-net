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

  records = aws_route53_zone.bunshin.name_servers
}

resource "aws_route53_record" "bunshin_apex_a" {
  #checkov:skip=CKV2_AWS_23:Points to an external IP, not an AWS resource
  zone_id = aws_route53_zone.bunshin.zone_id
  name    = var.prd_domain_name
  type    = "A"
  ttl     = 10

  records = [var.prd_records.a_record]
}

resource "aws_route53_record" "bunshin_apex_aaaa" {
  zone_id = aws_route53_zone.bunshin.zone_id
  name    = var.prd_domain_name
  type    = "AAAA"
  ttl     = 10

  records = [var.prd_records.aaaa_record]
}

resource "aws_route53_record" "bunshin_acme_challenge" {
  for_each = var.prd_records.acme_cnames

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

  records = [var.prd_records.a_record]
}

resource "aws_route53_record" "bunshin_region_aaaa" {
  for_each = local.prd_regions

  zone_id = aws_route53_zone.bunshin.zone_id
  name    = "*.${each.value}.${var.prd_domain_name}"
  type    = "AAAA"
  ttl     = 10

  records = [var.prd_records.aaaa_record]
}
