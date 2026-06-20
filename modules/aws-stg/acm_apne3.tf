resource "aws_acm_certificate" "apne3" {
  provider = aws.apne3

  domain_name               = "ap-northeast-3.${var.domain_name}"
  subject_alternative_names = ["*.ap-northeast-3.${var.domain_name}"]
  validation_method         = "DNS"
  tags                      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation_apne3" {
  allow_overwrite = true
  zone_id         = aws_route53_zone.zone.zone_id
  name            = tolist(aws_acm_certificate.apne3.domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.apne3.domain_validation_options)[0].resource_record_type
  ttl             = 60
  records         = [tolist(aws_acm_certificate.apne3.domain_validation_options)[0].resource_record_value]
}

resource "aws_acm_certificate_validation" "apne3" {
  provider = aws.apne3

  certificate_arn         = aws_acm_certificate.apne3.arn
  validation_record_fqdns = [aws_route53_record.acm_validation_apne3.fqdn]
}
