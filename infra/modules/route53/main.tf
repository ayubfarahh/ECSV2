module "zone" {
  source = "terraform-aws-modules/route53/aws"

  name    = "ecsv2.ayubs.uk"
  comment = "Public zone for terraform-aws-modules example"

  records = {
    alb = {
      name = "alb"
      type = "A"
      alias = {
        name    = var.alb_dns_name
        zone_id = var.alb_zone_id
      }

    }
  }
}