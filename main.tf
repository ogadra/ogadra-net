module "aws_prd" {
  source = "./modules/aws-prd"

  domain_name            = local.domain_name
  peer_apex_name_servers = module.ns1.apex_name_servers

  stg_domain_name   = local.stg_domain_name
  stg_apex_ns_rrset = local.stg_apex_ns_rrset

  prd_domain_name = local.prd_domain_name
  prd_records     = var.prd_records

  providers = {
    aws = aws.prd
  }
}

module "aws_stg" {
  source = "./modules/aws-stg"

  domain_name            = local.stg_domain_name
  peer_apex_name_servers = module.ns1.stg_apex_name_servers

  stg_google_cloud_records = var.stg_google_cloud_records
  stg_aws_records          = var.stg_aws_records
  stg_weights              = var.stg_weights
  stg_health_check_path    = local.stg_health_check_path

  providers = {
    aws = aws.stg
  }
}

module "ns1" {
  source = "./modules/ns1"

  domain_name            = local.domain_name
  peer_apex_name_servers = module.aws_prd.apex_name_servers

  stg_domain_name            = local.stg_domain_name
  stg_peer_apex_name_servers = module.aws_stg.apex_name_servers
  stg_google_cloud_records   = var.stg_google_cloud_records
  stg_aws_records            = var.stg_aws_records
  stg_weights                = var.stg_weights
  stg_health_check_path      = local.stg_health_check_path

  prd_domain_name     = local.prd_domain_name
  prd_ns_name_servers = module.aws_prd.name_servers
}
