# Health checks gate the apex weighted answers; they only exist while the
# apex is served active/active (i.e. the AWS apex alias is present).
resource "aws_route53_health_check" "apex_aws" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

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
  count = local.stg_aws_apex_alias != null ? 1 : 0

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
