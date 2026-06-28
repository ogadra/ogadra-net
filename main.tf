module "aws_prd" {
  source = "./modules/aws-prd"

  domain_name            = local.domain_name
  domain_ns_name_servers = local.domain_ns_name_servers

  stg_domain_name     = local.stg_domain_name
  stg_ns_name_servers = local.stg_ns_name_servers

  prd_domain_name     = local.prd_domain_name
  prd_ns_name_servers = module.google_prd.name_servers

  providers = {
    aws = aws.prd
  }
}

module "aws_stg" {
  source = "./modules/aws-stg"

  domain_name = local.stg_domain_name

  providers = {
    aws = aws.stg
  }
}

module "google_prd" {
  source = "./modules/google-prd"

  domain_name            = local.domain_name
  domain_ns_name_servers = local.domain_ns_name_servers
  acm_validation_records = module.aws_prd.acm_validation_records

  stg_domain_name     = local.stg_domain_name
  stg_ns_name_servers = local.stg_ns_name_servers

  prd_domain_name     = local.prd_domain_name
  prd_ns_name_servers = module.aws_prd.name_servers

  providers = {
    google = google.prd
  }
}

module "google_stg" {
  source = "./modules/google-stg"

  domain_name            = local.stg_domain_name
  acm_validation_records = module.aws_stg.acm_validation_records

  providers = {
    google = google.stg
  }
}
