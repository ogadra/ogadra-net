data "aws_route53_zone" "domain" {
  name         = local.domain_name
  private_zone = false
}

data "google_dns_managed_zone" "domain" {
  name = replace(local.domain_name, ".", "-")
}

data "aws_route53_zone" "tsujiura" {
  name         = local.tsujiura_domain_name
  private_zone = false
}

data "google_dns_managed_zone" "tsujiura" {
  project = var.tsujiura_project_id
  name    = replace(local.tsujiura_domain_name, ".", "-")
}
