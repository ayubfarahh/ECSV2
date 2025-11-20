output "private_subnets" {
  value = module.vpc.private_subnets

}

output "vpc" {
  value = module.vpc.vpc_id

}

output "public_subnets" {
  value = module.vpc.public_subnets

}