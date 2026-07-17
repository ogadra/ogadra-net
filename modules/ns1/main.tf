locals {
  ns1_name_servers = split(",", ns1_zone.zone.dns_servers)

  own_apex_name_servers = slice(sort([
    for name_server in local.ns1_name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  ns_records = {
    apex = {
      domain       = var.domain_name
      name_servers = concat(local.own_apex_name_servers, var.peer_apex_name_servers)
    }
    stg = {
      domain       = var.stg_domain_name
      name_servers = [for ns in var.stg_ns_name_servers : trimsuffix(ns, ".")]
    }
    prd = {
      domain       = var.prd_domain_name
      name_servers = [for ns in var.prd_ns_name_servers : trimsuffix(ns, ".")]
    }
  }
}

resource "ns1_zone" "zone" {
  zone                   = var.domain_name
  autogenerate_ns_record = false
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
}
