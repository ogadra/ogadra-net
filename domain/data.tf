data "aws_route53_zone" "domain" {
  name         = local.domain_name
  private_zone = false
}

data "ns1_zone" "domain" {
  zone = local.domain_name
}
