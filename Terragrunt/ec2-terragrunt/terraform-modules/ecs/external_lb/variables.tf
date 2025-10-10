#vars
variable "vpc_id" {
  type        = any
  description = "vpc id"
}

variable "load_balancer_associations" {
  description = "A jsonencoded map of load balancer associations"
  type        = string
  default     = "{}"
}


variable "port" {
  type        = number
  default     = 80
  description = "port for the ecs cluster service"
}

variable "cidr_block" {
  type        = string
  default     = "0.0.0.0/0"
  description = "cidr block to open up in external lb"
}

variable "idle_timeout" {
  type        = number
  default     = 3600
  description = "timeout"
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

variable "external_domain" {
  description = "external domain"
  type        = string
}

variable "subnets" {
  type        = list
  description = "subnets for the cluster"
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
