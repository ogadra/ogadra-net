locals {
  acm_validation_record_keys = distinct(concat(
    [
      for dvo in aws_acm_certificate.bunshin_global.domain_validation_options :
      "${dvo.resource_record_name}|${dvo.resource_record_type}|${dvo.resource_record_value}"
    ],
    [
      for dvo in aws_acm_certificate.bunshin_apne1.domain_validation_options :
      "${dvo.resource_record_name}|${dvo.resource_record_type}|${dvo.resource_record_value}"
    ],
    [
      for dvo in aws_acm_certificate.bunshin_apne3.domain_validation_options :
      "${dvo.resource_record_name}|${dvo.resource_record_type}|${dvo.resource_record_value}"
    ],
  ))

  acm_validation_records = {
    for record in local.acm_validation_record_keys : sha1(record) => {
      name   = split("|", record)[0]
      type   = split("|", record)[1]
      rrdata = split("|", record)[2]
    }
  }
}
