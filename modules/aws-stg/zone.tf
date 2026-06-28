resource "aws_route53_zone" "zone" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not required for this demo subdomain
  #checkov:skip=CKV2_AWS_39:DNS query logging is not required for this demo subdomain
  name = var.domain_name

  tags = local.tags
}

resource "aws_route53_record" "zone_ns" {
  allow_overwrite = true
  zone_id         = aws_route53_zone.zone.zone_id
  name            = var.domain_name
  type            = "NS"
  ttl             = 60

  records = concat(aws_route53_zone.zone.name_servers, var.peer_ns_name_servers)
}
