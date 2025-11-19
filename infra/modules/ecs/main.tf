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

  # Cluster capacity providers
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

      # Container definition(s)
      container_definitions = {

        ecs-sample = {
          cpu       = 256
          memory    = 512
          essential = true
          image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
          portMappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
              protocol      = "tcp"
            }
          ]
        }

      service_connect_configuration = {
        namespace = "example"
        service = [{
          client_alias = {
            port     = 80
            dns_name = "ecs-sample"
          }
          port_name      = "ecs-sample"
          discovery_name = "ecs-sample"
        }]
      }

      load_balancer = {
        service = {
          target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:1234567890:targetgroup/bluegreentarget1/209a844cd01825a4"
          container_name   = "ecs-sample"
          container_port   = 80
        }
      }

      subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]

      security_group_ingress_rules = {
        alb_3000 = {
          description                  = "Service port"
          from_port                    = 3000
          ip_protocol                  = "tcp"
          referenced_security_group_id = "sg-12345678"
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