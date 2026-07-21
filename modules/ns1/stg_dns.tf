resource "ns1_record" "stg_apex_ns" {
  zone   = ns1_zone.stg.zone
  domain = var.stg_domain_name
  type   = "NS"
  ttl    = 10

  dynamic "answers" {
    for_each = local.stg_apex_ns_name_servers
    content {
      answer = answers.value
    }
  }

  lifecycle {
    precondition {
      condition     = length(distinct(local.stg_apex_ns_name_servers)) == length(local.stg_apex_ns_name_servers)
      error_message = "Staging apex NS RRset must not contain duplicate name servers between own and peer authoritatives."
    }
  }
}

resource "ns1_record" "stg_a" {
  count = local.stg_aws_apex_alias == null ? 1 : 0

  zone   = ns1_zone.stg.zone
  domain = var.stg_domain_name
  type   = "A"
  ttl    = 10

  answers {
    answer = var.stg_google_cloud_records.a_record
  }
}

resource "ns1_record" "stg_aaaa" {
  count = local.stg_aws_apex_alias == null ? 1 : 0

  zone   = ns1_zone.stg.zone
  domain = var.stg_domain_name
  type   = "AAAA"
  ttl    = 10

  answers {
    answer = var.stg_google_cloud_records.aaaa_record
  }
}

moved {
  from = ns1_record.stg_a
  to   = ns1_record.stg_a[0]
}

moved {
  from = ns1_record.stg_aaaa
  to   = ns1_record.stg_aaaa[0]
}

resource "ns1_record" "stg_apex_alias" {
  count = local.stg_aws_apex_alias != null ? 1 : 0

  zone   = ns1_zone.stg.zone
  domain = var.stg_domain_name
  type   = "ALIAS"
  ttl    = 10

  answers {
    answer = trimsuffix(local.stg_aws_apex_alias.target, ".")
    meta = {
      weight = var.stg_weights.aws
      up     = jsonencode({ feed = ns1_datafeed.stg_apex_aws[0].id })
    }
  }

  answers {
    answer = "google-cloud.${var.stg_domain_name}"
    meta = {
      weight = var.stg_weights.google_cloud
      up     = jsonencode({ feed = ns1_datafeed.stg_apex_google_cloud[0].id })
    }
  }

  filters {
    filter = "up"
  }

  filters {
    filter = "weighted_shuffle"
  }

  filters {
    filter = "select_first_n"
    config = {
      N = 1
    }
  }
}

resource "ns1_record" "stg_user_dns_alias" {
  for_each = local.stg_aws_other_aliases

  zone   = ns1_zone.stg.zone
  domain = trimsuffix(each.value.name, ".")
  type   = "CNAME"
  ttl    = 10

  answers {
    answer = trimsuffix(each.value.target, ".")
  }
}

resource "ns1_record" "stg_google_cloud_a" {
  zone   = ns1_zone.stg.zone
  domain = "google-cloud.${var.stg_domain_name}"
  type   = "A"
  ttl    = 10

  answers {
    answer = var.stg_google_cloud_records.a_record
  }
}

resource "ns1_record" "stg_google_cloud_aaaa" {
  zone   = ns1_zone.stg.zone
  domain = "google-cloud.${var.stg_domain_name}"
  type   = "AAAA"
  ttl    = 10

  answers {
    answer = var.stg_google_cloud_records.aaaa_record
  }
}

resource "ns1_record" "stg_acme_challenge" {
  for_each = var.stg_google_cloud_records.acme_cnames

  zone   = ns1_zone.stg.zone
  domain = trimsuffix(each.value.name, ".")
  type   = "CNAME"
  ttl    = 60

  answers {
    answer = each.value.data
  }
}

resource "ns1_record" "stg_user_dns_acm_validation" {
  for_each = var.stg_aws_records.user_dns_acm_validation

  zone   = ns1_zone.stg.zone
  domain = trimsuffix(each.value.name, ".")
  type   = "CNAME"
  ttl    = 60

  answers {
    answer = each.value.data
  }
}

resource "ns1_record" "stg_region_a" {
  for_each = local.stg_regions

  zone   = ns1_zone.stg.zone
  domain = "*.${each.value}.${var.stg_domain_name}"
  type   = "A"
  ttl    = 10

  answers {
    answer = var.stg_google_cloud_records.a_record
  }
}

resource "ns1_record" "stg_region_aaaa" {
  for_each = local.stg_regions

  zone   = ns1_zone.stg.zone
  domain = "*.${each.value}.${var.stg_domain_name}"
  type   = "AAAA"
  ttl    = 10

  answers {
    answer = var.stg_google_cloud_records.aaaa_record
  }
}
