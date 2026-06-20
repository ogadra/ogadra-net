module "aws_prd" {
  source = "./modules/aws-prd"

  domain_name          = local.domain_name
  demo_ns_name_servers = module.aws_stg.name_servers

  providers = {
    aws = aws.prd
  }
}

module "aws_stg" {
  source = "./modules/aws-stg"

  domain_name = "demo.${local.domain_name}"

  providers = {
    aws = aws.stg
  }
}
