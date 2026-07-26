resource "aws_route53_health_check" "bunshin_apex_aws" {
  fqdn              = trimsuffix(local.prd_aws_apex_alias.target, ".")
  port              = 443
  type              = "HTTPS"
  resource_path     = var.prd_health_check_path
  enable_sni        = true
  request_interval  = 30
  failure_threshold = 1

  tags = merge(local.tags, { Name = "${var.prd_domain_name}-apex-aws" })
}

resource "aws_route53_health_check" "bunshin_apex_google_cloud" {
  ip_address        = var.prd_google_cloud_records.a_record
  fqdn              = var.prd_domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = var.prd_health_check_path
  enable_sni        = true
  request_interval  = 30
  failure_threshold = 1

  tags = merge(local.tags, { Name = "${var.prd_domain_name}-apex-google-cloud" })
}
