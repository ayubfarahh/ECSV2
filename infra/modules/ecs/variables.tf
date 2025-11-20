variable "private_subnets" {
  type = list(string)

}

variable "alb_target_group_arn" {
  type = string

}

variable "alb_sg_id" {
  type = string

}