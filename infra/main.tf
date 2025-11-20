module "vpc" {
  source = "./modules/vpc"

}

module "iam" {
  source = "./modules/iam"

}

module "ecs" {
  source = "./modules/ecs"

  private_subnets = module.vpc.private_subnets

}

module "alb" {
  source = "./modules/alb"

  public_subnets = module.vpc.public_subnets
  vpc            = module.vpc.vpc_id

}

module "route53" {
  source = "./modules/route53"

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
  
}

module "acm" {
  source = "./modules/acm"
}

