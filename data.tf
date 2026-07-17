data "aws_route53_zone" "domain" {
  provider = aws.prd

  name         = local.domain_name
  private_zone = false
}
