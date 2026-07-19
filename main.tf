module "aws_prd" {
  source = "./modules/aws-prd"

  domain_name            = local.domain_name
  peer_apex_name_servers = module.ns1.apex_name_servers

  stg_domain_name     = local.stg_domain_name
  stg_ns_name_servers = concat(module.aws_stg.apex_name_servers, module.ns1.stg_apex_name_servers)

  prd_domain_name = local.prd_domain_name

  providers = {
    aws = aws.prd
  }
}

module "aws_stg" {
  source = "./modules/aws-stg"

  domain_name            = local.stg_domain_name
  peer_apex_name_servers = module.ns1.stg_apex_name_servers

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

  prd_domain_name     = local.prd_domain_name
  prd_ns_name_servers = module.aws_prd.name_servers
}
