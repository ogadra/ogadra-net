resource "google_project_iam_member" "tsujiura_dns_admin" {
  project = var.tsujiura_project_id
  role    = "roles/dns.admin"
  member  = var.tsujiura_terraform_member
}
