data "aws_route53_zone" "domain" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "domain_ns" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.domain.zone_id
  name            = var.domain_name
  type            = "NS"
  ttl             = 60

  records = var.domain_ns_name_servers
}

resource "aws_route53_record" "demo_ns" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.stg_domain_name
  type    = "NS"
  ttl     = 60

  records = var.stg_ns_name_servers
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
  ttl     = 60

  records = concat(aws_route53_zone.bunshin.name_servers, var.prd_ns_name_servers)
}
