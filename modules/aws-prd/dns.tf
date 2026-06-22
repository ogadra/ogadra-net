data "aws_route53_zone" "domain" {
  name = var.domain_name
}

resource "aws_route53_record" "demo_ns" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "demo.${var.domain_name}"
  type    = "NS"
  ttl     = 300

  records = var.demo_ns_name_servers
}

resource "aws_route53_zone" "bunshin" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not required for this subdomain
  #checkov:skip=CKV2_AWS_39:DNS query logging is not required for this subdomain
  name = local.bunshin_domain_name

  tags = local.tags
}

resource "aws_route53_record" "bunshin_ns" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = local.bunshin_domain_name
  type    = "NS"
  ttl     = 300

  records = aws_route53_zone.bunshin.name_servers
}
