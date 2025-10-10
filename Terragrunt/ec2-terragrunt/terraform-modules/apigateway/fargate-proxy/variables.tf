#vars
variable "vpc_id" {
  type        = any
  description = "vpc id"
}

variable "port" {
  type        = number
  default     = 80
  description = "port for the ecs cluster service"
}

variable "cluster_name" {
  type        = string
  description = "name of the cluster"
}

variable "delete_protection" {
  description = "enable delete protection for lb"
  type        = bool
  default     = true
}

variable "aws_account_id" {
  description = "account number of aws account"
  type        = string
}

variable "subnets" {
  type        = list
  description = "subnets for the cluster"
}

variable "gateways" {
  type        = map
  description = "map of aws gateways"
}

variable "environment" {
  type        = string
  description = "environment"
}

variable "application_security_group_id" {
  description = "The ID of the application's security group"
  type        = string
}

variable "application_subnet_cidr" {
  description = "The subnet cidr in which the nlb will be provisioned"
  type        = string
}
