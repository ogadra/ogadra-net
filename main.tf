module "aws_prd" {
  source = "./modules/aws-prd"

  domain_name = local.domain_name

  stg_domain_name     = local.stg_domain_name
  stg_ns_name_servers = module.aws_stg.name_servers

  prd_domain_name = local.prd_domain_name

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

  domain_name = local.domain_name

  stg_domain_name     = local.stg_domain_name
  stg_ns_name_servers = module.aws_stg.name_servers

  prd_domain_name     = local.prd_domain_name
  prd_ns_name_servers = module.aws_prd.name_servers

  providers = {
    google = google.prd
  }
}
