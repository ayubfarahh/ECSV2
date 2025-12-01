resource "aws_ecs_cluster" "ecsv2_cluster" {
  name = "ecsv2-cluster"

}

resource "aws_ecs_task_definition" "ecsv2_task" {
  family = "ecsv2"
  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "40622738555.dkr.ecr.eu-west-2.amazonaws.com/ecsv2:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
  }])
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  vpc_id      = var.vpc

  ingress{
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress{
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "ecsv2_service" {
  name            = "ecsv2-service"
  cluster         = aws_ecs_cluster.ecsv2_cluster
  task_definition = aws_ecs_task_definition.ecsv2_task
  desired_count   = 1
  iam_role        = var.ecs_role


  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "app"
    container_port   = 8080
  }

  network_configuration {
    subnets = var.private_subnets
    security_groups = [ aws_security_group.ecs_sg.id ]
  }

  
}
