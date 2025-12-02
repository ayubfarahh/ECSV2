resource "aws_lb" "alb" {
  name               = "alb-ecsv2"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets


}

resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = var.vpc

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "alb-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc

  health_check {
    protocol = "HTTP"
    path     = "/healthz"
    port     = 8080
    matcher  = "200-299"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

