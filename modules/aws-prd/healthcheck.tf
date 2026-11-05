# The apex A and AAAA answers carry their own CALCULATED parent so that losing
# one address family fails over on its own instead of riding on the other.
resource "aws_route53_health_check" "bunshin_apex_aws_a_address" {
  for_each = toset(local.prd_aws_apex_a_records)

  ip_address        = each.value
  fqdn              = var.prd_domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = var.prd_health_check_path
  enable_sni        = true
  request_interval  = 30
  failure_threshold = 1

  tags = merge(local.tags, { Name = "${var.prd_domain_name}-apex-aws-${each.value}" })
}

resource "aws_route53_health_check" "bunshin_apex_aws_a" {
  type                   = "CALCULATED"
  child_health_threshold = 1
  child_healthchecks     = [for health_check in aws_route53_health_check.bunshin_apex_aws_a_address : health_check.id]

  tags = merge(local.tags, { Name = "${var.prd_domain_name}-apex-aws" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_health_check" "bunshin_apex_aws_aaaa_address" {
  for_each = toset(local.prd_aws_apex_aaaa_records)

  ip_address        = each.value
  fqdn              = var.prd_domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = var.prd_health_check_path
  enable_sni        = true
  request_interval  = 30
  failure_threshold = 1

  tags = merge(local.tags, { Name = "${var.prd_domain_name}-apex-aws-${each.value}" })
}

resource "aws_route53_health_check" "bunshin_apex_aws_aaaa" {
  count = length(local.prd_aws_apex_aaaa_records) > 0 ? 1 : 0

  type                   = "CALCULATED"
  child_health_threshold = 1
  child_healthchecks     = [for health_check in aws_route53_health_check.bunshin_apex_aws_aaaa_address : health_check.id]

  tags = merge(local.tags, { Name = "${var.prd_domain_name}-apex-aws-ipv6" })

  lifecycle {
    create_before_destroy = true
  }
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

moved {
  from = aws_route53_health_check.bunshin_apex_aws_address
  to   = aws_route53_health_check.bunshin_apex_aws_a_address
}

moved {
  from = aws_route53_health_check.bunshin_apex_aws
  to   = aws_route53_health_check.bunshin_apex_aws_a
}
