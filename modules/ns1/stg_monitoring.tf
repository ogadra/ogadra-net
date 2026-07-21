# Monitoring jobs feed the apex ALIAS answers' up metadata; they only exist
# while the apex is served active/active (i.e. the AWS apex alias is present).
# virtual_host keeps the probed SNI/Host identical to real apex traffic.
resource "ns1_monitoringjob" "stg_apex_aws" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

  name          = "${var.stg_domain_name}-apex-aws"
  job_type      = "http"
  active        = true
  regions       = ["lga", "sjc", "sin"]
  frequency     = 60
  rapid_recheck = true
  policy        = "quorum"
  notify_list   = ns1_notifylist.monitoring[0].id

  config = {
    method       = "GET"
    url          = "https://${trimsuffix(local.stg_aws_apex_alias.target, ".")}${var.stg_health_check_path}"
    virtual_host = var.stg_domain_name
  }

  rules {
    key        = "status_code"
    comparison = "=="
    value      = "200"
  }
}

resource "ns1_monitoringjob" "stg_apex_google_cloud" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

  name          = "${var.stg_domain_name}-apex-google-cloud"
  job_type      = "http"
  active        = true
  regions       = ["lga", "sjc", "sin"]
  frequency     = 60
  rapid_recheck = true
  policy        = "quorum"
  notify_list   = ns1_notifylist.monitoring[0].id

  config = {
    method       = "GET"
    url          = "https://${var.stg_google_cloud_records.a_record}${var.stg_health_check_path}"
    virtual_host = var.stg_domain_name
  }

  rules {
    key        = "status_code"
    comparison = "=="
    value      = "200"
  }
}

resource "ns1_datasource" "monitoring" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

  name       = "monitoring"
  sourcetype = "nsone_monitoring"
}

# Jobs only push status changes to the data source through a notify list with
# a datafeed notifier; without it the connected feeds never update.
resource "ns1_notifylist" "monitoring" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

  name = "monitoring-datafeed"

  notifications {
    type = "datafeed"
    config = {
      sourceid = ns1_datasource.monitoring[0].id
    }
  }
}

resource "ns1_datafeed" "stg_apex_aws" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

  name      = "${var.stg_domain_name}-apex-aws"
  source_id = ns1_datasource.monitoring[0].id

  config = {
    jobid = ns1_monitoringjob.stg_apex_aws[0].id
  }
}

resource "ns1_datafeed" "stg_apex_google_cloud" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

  name      = "${var.stg_domain_name}-apex-google-cloud"
  source_id = ns1_datasource.monitoring[0].id

  config = {
    jobid = ns1_monitoringjob.stg_apex_google_cloud[0].id
  }
}
