locals {
  tsujiura_domain_name     = "tsujiura.${local.domain_name}"
  tsujiura_wildcard_target = "192.0.2.1"

  tsujiura_apex_ns_rrset = concat(
    module.aws_prd.tsujiura_apex_name_servers,
    module.google_cloud_prd.tsujiura_apex_name_servers,
  )
}

module "aws_prd" {
  source = "./modules/aws-prd"

  domain_name   = local.domain_name
  apex_ns_rrset = local.apex_ns_rrset

  prd_domain_name          = local.prd_domain_name
  prd_apex_ns_rrset        = local.prd_apex_ns_rrset
  prd_google_cloud_records = var.prd_google_cloud_records
  prd_aws_records          = var.prd_aws_records
  prd_weights              = var.prd_weights
  prd_health_check_path    = local.prd_health_check_path

  tsujiura_domain_name     = local.tsujiura_domain_name
  tsujiura_apex_ns_rrset   = local.tsujiura_apex_ns_rrset
  tsujiura_wildcard_target = local.tsujiura_wildcard_target

  providers = {
    aws = aws.prd
  }
}

module "google_cloud_prd" {
  source = "./modules/google-cloud-prd"

  domain_name   = local.domain_name
  apex_ns_rrset = local.apex_ns_rrset

  prd_domain_name          = local.prd_domain_name
  prd_apex_ns_rrset        = local.prd_apex_ns_rrset
  prd_google_cloud_records = var.prd_google_cloud_records
  prd_aws_records          = var.prd_aws_records
  prd_weights              = var.prd_weights
  prd_health_check_path    = local.prd_health_check_path

  tsujiura_domain_name      = local.tsujiura_domain_name
  tsujiura_apex_ns_rrset    = local.tsujiura_apex_ns_rrset
  tsujiura_wildcard_target  = local.tsujiura_wildcard_target
  tsujiura_project_id       = var.tsujiura_project_id
  tsujiura_terraform_member = var.tsujiura_terraform_member

  providers = {
    google = google.prd
  }
}
