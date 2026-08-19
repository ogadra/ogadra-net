module "aws_prd" {
  source = "./modules/aws-prd"

  domain_name = local.domain_name

  prd_domain_name          = local.prd_domain_name
  prd_apex_ns_rrset        = local.prd_apex_ns_rrset
  prd_google_cloud_records = var.prd_google_cloud_records
  prd_aws_records          = var.prd_aws_records
  prd_weights              = var.prd_weights
  prd_health_check_path    = local.prd_health_check_path

  providers = {
    aws = aws.prd
  }
}
