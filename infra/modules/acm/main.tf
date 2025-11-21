module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.1.1"

  domain_name = "ecsv2.ayubs.uk"
  zone_id     = var.hosted_zone_id

  validation_method = "DNS"

  wait_for_validation = true

}