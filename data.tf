data "aws_route53_zone" "domain" {
  provider = aws.prd

  name         = local.domain_name
  private_zone = false
}

data "google_dns_managed_zone" "domain" {
  provider = google.prd

  name = replace(local.domain_name, ".", "-")
}
