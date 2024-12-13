data "aws_route53_zone" "main" {
  name = "tycm2-infra.fr"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "tycm2-infra.fr"
  zone_id     = data.aws_route53_zone.main.zone_id

  validation_method = "DNS"

  # subject_alternative_names = [
  #   "*.tycm2-infra.fr",
  #   "awshift.tycm2-infra.fr" 
  # ]

  wait_for_validation = true

  tags = {
    Name = "tycm2-infra.fr"
  }
}

resource "aws_route53_record" "awshift" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "awshift.tycm2-infra.fr"
  type    = "CNAME"
  ttl     = 300

  records = module.master_instances[0].public_ips[0]
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.shift.awshift.tycm2-infra.fr"
  type    = "CNAME"
  ttl     = 300

  records = module.master_instances[0].public_ips[0]
}

resource "aws_route53_record" "api-int" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api-int.shift.awshift.tycm2-infra.fr"
  type    = "CNAME"
  ttl     = 300

  records = module.master_instances[0].public_ips[0]
}

resource "aws_route53_record" "apps" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = ".apps.shift.awshift.tycm2-infra.fr"
  type    = "CNAME"
  ttl     = 300

  records = module.master_instances[0].public_ips[0]
}

resource "aws_route53_record" "bootstrap" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "bootstrap.shift.awshift.tycm2-infra.fr"
  type    = "CNAME"
  ttl     = 300

  records = module.master_instances[0].public_ips[0]
}

resource "aws_route53_record" "master" {
  for_each = toset(["master1", "master2", "master3"])

  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${each.key}.shift.awshift.tycm2-infra.fr"
  type    = "CNAME"
  ttl     = 300

  records = [element(module.master_instances[each.key == "master1" ? 0 : each.key == "master2" ? 1 : 2].public_ips, 0)]
}

resource "aws_route53_record" "worker" {
  for_each = toset(["worker1", "worker2", "worker3"])

  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${each.key}.shift.awshift.tycm2-infra.fr"
  type    = "CNAME"
  ttl     = 300

  records = [element(module.worker_instances[each.key == "worker1" ? 0 : each.key == "worker2" ? 1 : 2].public_ips, 0)]
}
