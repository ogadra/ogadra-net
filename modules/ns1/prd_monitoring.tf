resource "ns1_monitoringjob" "prd_apex_aws" {
  name          = "${var.prd_domain_name}-apex-aws"
  job_type      = "http"
  active        = true
  regions       = ["sin", "syd", "ams"]
  frequency     = 60
  rapid_recheck = true
  policy        = "quorum"
  notify_list   = ns1_notifylist.monitoring.id

  config = {
    method          = "GET"
    url             = "https://${trimsuffix(local.prd_aws_apex_alias.target, ".")}${var.prd_health_check_path}"
    virtual_host    = var.prd_domain_name
    connect_timeout = "5"
    follow_redirect = "false"
    idle_timeout    = "3"
    ipv6            = "false"
    tls_add_verify  = "false"
    user_agent      = "NS1 HTTP Monitoring Job"
  }

  rules {
    key        = "status_code"
    comparison = "=="
    value      = "200"
  }
}

resource "ns1_monitoringjob" "prd_apex_google_cloud" {
  name          = "${var.prd_domain_name}-apex-google-cloud"
  job_type      = "http"
  active        = true
  regions       = ["sin", "syd", "ams"]
  frequency     = 60
  rapid_recheck = true
  policy        = "quorum"
  notify_list   = ns1_notifylist.monitoring.id

  config = {
    method          = "GET"
    url             = "https://${var.prd_google_cloud_records.a_record}${var.prd_health_check_path}"
    virtual_host    = var.prd_domain_name
    connect_timeout = "5"
    follow_redirect = "false"
    idle_timeout    = "3"
    ipv6            = "false"
    tls_add_verify  = "false"
    user_agent      = "NS1 HTTP Monitoring Job"
  }

  rules {
    key        = "status_code"
    comparison = "=="
    value      = "200"
  }
}

resource "ns1_datafeed" "prd_apex_aws" {
  name      = "${var.prd_domain_name}-apex-aws"
  source_id = ns1_datasource.monitoring.id

  config = {
    jobid = ns1_monitoringjob.prd_apex_aws.id
  }
}

resource "ns1_datafeed" "prd_apex_google_cloud" {
  name      = "${var.prd_domain_name}-apex-google-cloud"
  source_id = ns1_datasource.monitoring.id

  config = {
    jobid = ns1_monitoringjob.prd_apex_google_cloud.id
  }
}
