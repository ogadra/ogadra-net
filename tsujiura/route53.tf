resource "aws_route53_zone" "tsujiura" {
  #checkov:skip=CKV2_AWS_38:Signing here alone would make resolvers reject the answers of the unsigned peer Cloud DNS zone
  #checkov:skip=CKV2_AWS_39:Query logging is configured in the Tsujiura repository
  name = local.tsujiura_domain_name

  tags = local.common_tags
}

resource "aws_route53_record" "tsujiura_ns" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = local.tsujiura_domain_name
  type    = "NS"
  ttl     = 10

  records = local.tsujiura_apex_ns_rrset

  lifecycle {
    precondition {
      condition     = length(local.tsujiura_apex_ns_rrset) == 8
      error_message = "Tsujiura apex NS RRset must contain all 8 name servers of both providers."
    }

    precondition {
      condition     = length(distinct(local.tsujiura_apex_ns_rrset)) == length(local.tsujiura_apex_ns_rrset)
      error_message = "Tsujiura apex NS RRset must not contain duplicates between the two providers."
    }
  }
}

resource "aws_route53_record" "tsujiura_apex_ns" {
  allow_overwrite = true
  zone_id         = aws_route53_zone.tsujiura.zone_id
  name            = local.tsujiura_domain_name
  type            = "NS"
  ttl             = 10

  records = local.tsujiura_apex_ns_rrset
}

resource "aws_route53_record" "tsujiura_apex_a" {
  #checkov:skip=CKV2_AWS_23:Points to Global Accelerator and Google Cloud LB IPs managed in the Tsujiura repository
  zone_id = aws_route53_zone.tsujiura.zone_id
  name    = local.tsujiura_domain_name
  type    = "A"
  ttl     = 10

  records = local.tsujiura_frontend_a_rrset
}

resource "aws_route53_record" "tsujiura_wildcard_a" {
  #checkov:skip=CKV2_AWS_23:Points to Global Accelerator and Google Cloud LB IPs managed in the Tsujiura repository
  zone_id = aws_route53_zone.tsujiura.zone_id
  name    = "*.${local.tsujiura_domain_name}"
  type    = "A"
  ttl     = 10

  records = local.tsujiura_frontend_a_rrset
}

resource "aws_route53_record" "tsujiura_validation" {
  for_each = var.tsujiura_validation_cnames

  zone_id = aws_route53_zone.tsujiura.zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = 60

  records = [each.value.data]
}
