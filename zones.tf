module "aws_prd" {
  source = "./modules/aws-prd"

  domain_name = local.domain_name
}
