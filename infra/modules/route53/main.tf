resource "aws_route53_zone" "ecsv2" {
  name = "ecsv2.ayubs.uk"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.ecsv2.zone_id
  name    = "ecsv2.ayubs.uk"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}