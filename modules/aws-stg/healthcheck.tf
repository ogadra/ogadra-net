# Health checks gate the apex weighted answers served active/active from
# the AWS apex alias and the Google Cloud GLB.
resource "aws_route53_health_check" "apex_aws" {
  fqdn              = trimsuffix(local.stg_aws_apex_alias.target, ".")
  port              = 443
  type              = "HTTPS"
  resource_path     = var.stg_health_check_path
  enable_sni        = true
  request_interval  = 30
  failure_threshold = 1

  tags = merge(local.tags, { Name = "${var.domain_name}-apex-aws" })
}

resource "aws_route53_health_check" "apex_google_cloud" {
  ip_address        = var.stg_google_cloud_records.a_record
  fqdn              = var.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = var.stg_health_check_path
  enable_sni        = true
  request_interval  = 30
  failure_threshold = 1

  tags = merge(local.tags, { Name = "${var.domain_name}-apex-google-cloud" })
}
