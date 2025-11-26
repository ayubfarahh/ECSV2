module "vpc" {
  source = "./modules/vpc"

}

module "iam" {
  source = "./modules/iam"

}

module "ecs" {
  source = "./modules/ecs"

  private_subnets      = module.vpc.private_subnets
  public_subnets       = module.vpc.public_subnets
  alb_sg_id            = module.alb.alb_sg_id
  alb_target_group_arn = module.alb.alb_target_group_arn
  ecs_role             = module.iam.ecs_role
  ecs_task_role_arn    = module.iam.ecs_task_role_arn

}

module "alb" {
  source = "./modules/alb"

  public_subnets = module.vpc.public_subnets
  vpc            = module.vpc.vpc_id
  acm_arn        = module.acm.acm_arn

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

module "dynamodb" {
  source             = "./modules/dynamodb"
  ecs_role_name      = module.iam.ecs_role_name
  ecs_task_role_name = module.iam.ecs_task_role_name

}