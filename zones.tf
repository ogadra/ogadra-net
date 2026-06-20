module "aws_prd" {
  source = "./modules/aws-prd"

  domain_name    = local.domain_name
  domain_contact = var.domain_contact
}
