variable "private_subnets" {
  type = list(string)

}

variable "alb_sg_id" {
  type = string

}

variable "public_subnets" {
  type = list(string)

}

variable "ecs_role" {
  type = string

}

variable "ecs_task_role_arn" {
  type = string

}


variable "alb_target_group_arn" {
  type = string
}
