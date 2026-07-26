locals {
  ns1_name_servers = split(",", ns1_zone.zone.dns_servers)

  own_apex_name_servers = slice(sort([
    for name_server in local.ns1_name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  apex_ns_name_servers = concat(local.own_apex_name_servers, var.peer_apex_name_servers)

  stg_regions = toset([
    "asia-northeast1",
    "asia-northeast2",
  ])

  ns_records = {
    apex = {
      domain       = var.domain_name
      name_servers = local.apex_ns_name_servers
    }
    stg = {
      domain       = var.stg_domain_name
      name_servers = local.stg_apex_ns_name_servers
    }
    prd = {
      domain       = var.prd_domain_name
      name_servers = local.prd_apex_ns_name_servers
    }
  }
}

resource "ns1_zone" "zone" {
  zone                   = var.domain_name
  autogenerate_ns_record = false

  lifecycle {
    postcondition {
      condition     = length(split(",", self.dns_servers)) >= 3
      error_message = "NS1 zone must expose at least 3 name servers for apex mirror."
    }
  }
}

resource "ns1_record" "ns" {
  for_each = local.ns_records

  zone   = ns1_zone.zone.zone
  domain = each.value.domain
  type   = "NS"
  ttl    = 10

  dynamic "answers" {
    for_each = each.value.name_servers
    content {
      answer = answers.value
    }
  }

  lifecycle {
    precondition {
      condition     = length(distinct(each.value.name_servers)) == length(each.value.name_servers)
      error_message = "NS RRset for ${each.key} must not contain duplicate name servers between own and peer authoritatives."
    }
  }
}
