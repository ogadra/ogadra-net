resource "ns1_record" "prd_apex_ns" {
  zone   = ns1_zone.prd.zone
  domain = var.prd_domain_name
  type   = "NS"
  ttl    = 10

  dynamic "answers" {
    for_each = local.prd_apex_ns_name_servers
    content {
      answer = answers.value
    }
  }

  lifecycle {
    precondition {
      condition     = length(distinct(local.prd_apex_ns_name_servers)) == length(local.prd_apex_ns_name_servers)
      error_message = "Production apex NS RRset must not contain duplicate name servers between own and peer authoritatives."
    }
  }
}

resource "ns1_record" "prd_apex_alias" {
  zone   = ns1_zone.prd.zone
  domain = var.prd_domain_name
  type   = "ALIAS"
  ttl    = 10

  answers {
    answer = trimsuffix(local.prd_aws_apex_alias.target, ".")
    meta = {
      weight = var.prd_weights.aws
      up     = jsonencode({ feed = ns1_datafeed.prd_apex_aws.id })
    }
  }

  answers {
    answer = "google-cloud.${var.prd_domain_name}"
    meta = {
      weight = var.prd_weights.google_cloud
      up     = jsonencode({ feed = ns1_datafeed.prd_apex_google_cloud.id })
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

resource "ns1_record" "prd_user_dns_alias" {
  for_each = local.prd_aws_other_aliases

  zone   = ns1_zone.prd.zone
  domain = trimsuffix(each.value.name, ".")
  type   = "CNAME"
  ttl    = 10

  answers {
    answer = trimsuffix(each.value.target, ".")
  }
}

resource "ns1_record" "prd_google_cloud_a" {
  zone   = ns1_zone.prd.zone
  domain = "google-cloud.${var.prd_domain_name}"
  type   = "A"
  ttl    = 10

  answers {
    answer = var.prd_google_cloud_records.a_record
  }
}

resource "ns1_record" "prd_google_cloud_aaaa" {
  zone   = ns1_zone.prd.zone
  domain = "google-cloud.${var.prd_domain_name}"
  type   = "AAAA"
  ttl    = 10

  answers {
    answer = var.prd_google_cloud_records.aaaa_record
  }
}

resource "ns1_record" "prd_acme_challenge" {
  for_each = var.prd_google_cloud_records.acme_cnames

  zone   = ns1_zone.prd.zone
  domain = trimsuffix(each.value.name, ".")
  type   = "CNAME"
  ttl    = 60

  answers {
    answer = each.value.data
  }
}

resource "ns1_record" "prd_user_dns_acm_validation" {
  for_each = var.prd_aws_records.user_dns_acm_validation

  zone   = ns1_zone.prd.zone
  domain = trimsuffix(each.value.name, ".")
  type   = "CNAME"
  ttl    = 60

  answers {
    answer = each.value.data
  }
}

resource "ns1_record" "prd_region_a" {
  for_each = local.prd_regions

  zone   = ns1_zone.prd.zone
  domain = "*.${each.value}.${var.prd_domain_name}"
  type   = "A"
  ttl    = 10

  answers {
    answer = var.prd_google_cloud_records.a_record
  }
}

resource "ns1_record" "prd_region_aaaa" {
  for_each = local.prd_regions

  zone   = ns1_zone.prd.zone
  domain = "*.${each.value}.${var.prd_domain_name}"
  type   = "AAAA"
  ttl    = 10

  answers {
    answer = var.prd_google_cloud_records.aaaa_record
  }
}
