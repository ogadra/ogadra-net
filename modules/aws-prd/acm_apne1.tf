resource "aws_acm_certificate" "bunshin_apne1" {
  provider = aws.apne1

  domain_name               = var.prd_domain_name
  subject_alternative_names = ["*.${var.prd_domain_name}"]
  validation_method         = "DNS"
  tags                      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "bunshin_acm_validation_apne1" {
  for_each = {
    for dvo in aws_acm_certificate.bunshin_apne1.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = aws_route53_zone.bunshin.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "bunshin_apne1" {
  provider = aws.apne1

  certificate_arn         = aws_acm_certificate.bunshin_apne1.arn
  validation_record_fqdns = [for record in aws_route53_record.bunshin_acm_validation_apne1 : record.fqdn]
}
