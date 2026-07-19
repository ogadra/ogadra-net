locals {
  stg_ns1_name_servers = split(",", ns1_zone.stg.dns_servers)

  stg_own_apex_name_servers = slice(sort([
    for name_server in local.stg_ns1_name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  stg_apex_ns_name_servers = concat(local.stg_own_apex_name_servers, var.stg_peer_apex_name_servers)
}

resource "ns1_zone" "stg" {
  zone                   = var.stg_domain_name
  autogenerate_ns_record = false

  lifecycle {
    postcondition {
      condition     = length(split(",", self.dns_servers)) >= 3
      error_message = "NS1 staging zone must expose at least 3 name servers for apex mirror."
    }
  }
}

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
