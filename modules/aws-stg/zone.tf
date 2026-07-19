resource "aws_route53_zone" "zone" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not required for this demo subdomain
  #checkov:skip=CKV2_AWS_39:DNS query logging is not required for this demo subdomain
  name = var.domain_name

  tags = local.tags

  lifecycle {
    postcondition {
      condition     = length(self.name_servers) >= 3
      error_message = "AWS Route53 hosted zone must expose at least 3 name servers for apex mirror."
    }
  }
}
