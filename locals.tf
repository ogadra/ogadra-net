locals {
  domain_name   = "ogadra.net"
  stg_subdomain = "demo"
  prd_subdomain = "bunshin"

  stg_domain_name = "${local.stg_subdomain}.${local.domain_name}"
  prd_domain_name = "${local.prd_subdomain}.${local.domain_name}"

  google_prd_impersonate_service_account = "${var.impersonate_service_account}@${var.google_prd_project_id}.iam.gserviceaccount.com"
}
