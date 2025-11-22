variable "vpc" {
  type = string
}

variable "public_subnets" {
  type = list(string)

}

variable "acm_arn" {
  type = string

}