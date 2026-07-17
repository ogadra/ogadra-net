resource "ns1_zone" "zone" {
  zone                   = trimsuffix(var.domain_name, ".")
  autogenerate_ns_record = false
}

resource "ns1_record" "zone_ns" {
  zone   = ns1_zone.zone.zone
  domain = ns1_zone.zone.zone
  type   = "NS"
  ttl    = 60

  dynamic "answers" {
    for_each = [for ns in var.domain_ns_name_servers : trimsuffix(ns, ".")]
    content {
      answer = answers.value
    }
  }
}

resource "ns1_record" "stg_ns" {
  zone   = ns1_zone.zone.zone
  domain = trimsuffix(var.stg_domain_name, ".")
  type   = "NS"
  ttl    = 60

  dynamic "answers" {
    for_each = [for ns in var.stg_ns_name_servers : trimsuffix(ns, ".")]
    content {
      answer = answers.value
    }
  }
}

resource "ns1_record" "prd_ns" {
  zone   = ns1_zone.zone.zone
  domain = trimsuffix(var.prd_domain_name, ".")
  type   = "NS"
  ttl    = 60

  dynamic "answers" {
    for_each = [for ns in var.prd_ns_name_servers : trimsuffix(ns, ".")]
    content {
      answer = answers.value
    }
  }
}
