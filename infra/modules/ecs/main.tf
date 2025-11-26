module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-integrated"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  # Capacity provider strategy
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }


  services = {
    ecsdemo-frontend = {
      cpu    = 256
      memory = 512

      execution_role_arn = var.ecs_role
      task_role_arn      = var.ecs_task_role_arn

      container_definitions = {
        fluent-bit = {
          cpu       = 256
          memory    = 512
          essential = true
          image     = "940622738555.dkr.ecr.eu-west-2.amazonaws.com/ecsv2:latest"

          portMappings = [
            {
              name          = "ecsv2"
              containerPort = 8080
              protocol      = "tcp"
            }
          ]

          environment = [
            {
              name  = "TABLE_NAME"
              value = "ecsv2-table"
            },
            {
              name  = "AWS_REGION"
              value = "eu-west-2"
            }
          ]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = var.alb_target_group_arn
          container_name   = "fluent-bit"
          container_port   = 8080
        }
      }

      subnet_ids = var.private_subnets

      security_group_ingress_rules = {
        alb_3000 = {
          description                  = "Allow ALB to reach ECS tasks"
          from_port                    = 8080
          to_port                      = 8080
          ip_protocol                  = "tcp"
          referenced_security_group_id = var.alb_sg_id
        }
      }

      security_group_egress_rules = {
        all = {
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }
    }
  }
}