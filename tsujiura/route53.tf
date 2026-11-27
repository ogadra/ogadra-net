resource "aws_route53_record" "tsujiura_ns" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = local.tsujiura_domain_name
  type    = "NS"
  ttl     = 10

  records = local.tsujiura_ns_rrset

  lifecycle {
    precondition {
      condition     = length(local.tsujiura_ns_rrset) == 8
      error_message = "Tsujiura NS RRset must contain all 8 name servers of both providers."
    }

    precondition {
      condition     = length(distinct(local.tsujiura_ns_rrset)) == length(local.tsujiura_ns_rrset)
      error_message = "Tsujiura NS RRset must not contain duplicates between the two providers."
    }
  }
}
