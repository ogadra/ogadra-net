resource "aws_acm_certificate" "global" {
  provider = aws.global

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  tags                      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation_global" {
  allow_overwrite = true
  zone_id         = aws_route53_zone.zone.zone_id
  name            = tolist(aws_acm_certificate.global.domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.global.domain_validation_options)[0].resource_record_type
  ttl             = 60
  records         = [tolist(aws_acm_certificate.global.domain_validation_options)[0].resource_record_value]
}

resource "aws_acm_certificate_validation" "global" {
  provider = aws.global

  certificate_arn         = aws_acm_certificate.global.arn
  validation_record_fqdns = [aws_route53_record.acm_validation_global.fqdn]
}
