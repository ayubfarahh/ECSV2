module "vpc" {
  source = "./modules/vpc"

}

module "iam" {
  source = "./modules/iam"

}

module "ecs" {
  source = "./modules/ecs"

  private_subnets      = module.vpc.private_subnets
  alb_sg_id            = module.alb.alb_sg_id
  alb_target_group_arn = module.alb.alb_target_group_arn

}

module "alb" {
  source = "./modules/alb"

  public_subnets = module.vpc.public_subnets
  vpc            = module.vpc.vpc_id

}

module "route53" {
  source = "./modules/route53"

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id

}

module "acm" {
  source = "./modules/acm"

  hosted_zone_id = module.route53.hosted_zone_id
}

