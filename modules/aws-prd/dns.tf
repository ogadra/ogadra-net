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
