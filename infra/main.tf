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