#vars
variable "lb_arn" {
  description = "load balancer arn"
  type        = string
}

variable "app_name" {
  description = "app name"
  type        = string
}

resource "aws_api_gateway_vpc_link" "link" {
  name        = var.app_name
  description = var.app_name
  target_arns = [var.lb_arn]
}
