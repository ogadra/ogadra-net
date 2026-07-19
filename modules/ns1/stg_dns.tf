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
  zone   = ns1_zone.stg.zone
  domain = var.stg_domain_name
  type   = "A"
  ttl    = 300

  answers {
    answer = var.stg_ipv4_address
  }
}

resource "ns1_record" "stg_aaaa" {
  zone   = ns1_zone.stg.zone
  domain = var.stg_domain_name
  type   = "AAAA"
  ttl    = 300

  answers {
    answer = var.stg_ipv6_address
  }
}
