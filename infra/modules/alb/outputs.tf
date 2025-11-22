output "alb_dns_name" {
  value = module.alb.dns_name

}

output "alb_zone_id" {
  value = module.alb.zone_id

}

output "alb_target_group_arn" {
  value = module.alb.target_groups["ex-instance"].arn

}

output "alb_sg_id" {
  value = module.alb.security_group_id
}