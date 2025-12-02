resource "aws_ecs_cluster" "ecsv2_cluster" {
  name = "ecsv2-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/ecsv2"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ecsv2_task" {
  family             = "ecsv2"
  execution_role_arn = var.ecs_role
  task_role_arn      = var.ecs_task_role_arn

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "940622738555.dkr.ecr.eu-west-2.amazonaws.com/ecsv2:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "TABLE_NAME"
          value = "ecsv2-table"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }

    }
  ])
}


resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = var.vpc

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "ecsv2_service" {
  name            = "ecsv2-service"
  cluster         = aws_ecs_cluster.ecsv2_cluster.id
  task_definition = aws_ecs_task_definition.ecsv2_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"


  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "app"
    container_port   = 8080
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }


}
