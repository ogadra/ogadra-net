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

resource "aws_route53_record" "apex_a" {
  #checkov:skip=CKV2_AWS_23:Points to an external IP, not an AWS resource
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 10

  records = [var.stg_records.a_record]
}

resource "aws_route53_record" "apex_aaaa" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "AAAA"
  ttl     = 10

  records = [var.stg_records.aaaa_record]
}

resource "aws_route53_record" "acme_challenge" {
  for_each = var.stg_records.acme_cnames

  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = 60

  records = [each.value.data]
}
