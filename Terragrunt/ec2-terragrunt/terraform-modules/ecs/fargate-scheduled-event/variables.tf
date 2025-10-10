variable "scheduled_tasks" {
  description = " A map of task "
  type        = map
  default     = {}
}

variable "application_name" {
  description = "application name"
  type        = string
}

variable "container_name" {
  description = "container name"
  type        = string
  default     = "app"
}

variable "subnets" {
  description = "subnets for task"
  type        = list
}

variable "aws_account_id" {
  description = "account"
  type        = string
}

variable "ecs_cluster_name" {
  description = "cluster name"
  type        = string
  default     = ""
}

variable "task_definition_arn" {
  description = "task definition arn"
  type        = string
}

variable "security_groups" {
  description = "List of security group ids to associate with the service"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "The name of the environment to deploy"
  type        = string
}

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket used to store terraform remote state"
  type        = string
  default     = null
}

variable "terraform_state_aws_region" {
  description = "The AWS region of the S3 bucket used to store terraform remote state"
  type        = string
  default     = "us-east-1"
}

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "remote_state_paths" {
  description = "A map of names to paths relative to region/vpc-name"
  type        = map(string)
  default     = {}
}

