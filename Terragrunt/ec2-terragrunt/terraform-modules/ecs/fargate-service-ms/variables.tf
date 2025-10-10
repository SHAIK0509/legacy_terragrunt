variable "name" {
  description = "The full name of the service to deploy"
  type        = string
}

variable "cluster" {
  description = "The name of the ecs cluster on which this service will run"
  type        = string
}

variable "external_lb" {
  description = "arn of the external_lb"
  type        = string
  default     = ""
}

variable "external_domain" {
  description = "The name of the external domain service will run"
  type        = string
}

variable "network_lb_container_name" {
  description = " the name of the container to target"
  type        = string
  default     = "app"
}

variable "network_lb_port" {
  description = "the port to target"
  type        = number
  default     = 80
}

variable "network_lb" {
  description = "true if network lb is needed empty if not"
  type        = string
  default     = ""
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets in which this service is allowed to run"
}

variable "container_definitions" {
  description = "A jsonencoded list of ECS Fargate container definitions"
  type        = string
}

variable "command" {
  description = "the start command for the container defintion"
  type        = list(string)
}

variable "allowed_deployment_environments" {
  description = "A list of allowed environments"
  type        = list(string)
  default     = ["dev", "stage", "prod", "shared-services"]
}

variable "template_variables" {
  description = "A map of placeholder values to interpolate in various helper module resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "The AWS region in which to create resources (and lookup ecr images)"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public ip address to this service"
  type        = bool
  default     = false
}

variable "task_cpu" {
  description = "The CPU assignment for the ECS Fargate task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "The MEMORY assignment for the ECS Fargate task"
  type        = number
  default     = 256
}

variable "do_autoscaling" {
  description = "flag for autoscaling"
  type        = number
  default     = 0
}

variable "cooldown_secs" {
  description = "autoscaling cooldown seconds"
  type        = number
  default     = 120
}

variable "max_capacity" {
  description = "max tasks"
  type        = number
  default     = 0
}

variable "min_capacity" {
  description = "min tasks"
  type        = number
  default     = 0
}

variable "scale_target" {
  description = "cpu % to scale"
  type        = number
  default     = 0
}


variable "platform_version" {
  description = "The ECS Fargate platform version"
  type        = string
  default     = "LATEST" // NOTE: LATEST does not always mean NEWEST
}

variable "security_groups" {
  description = "List of security group ids to associate with the service"
  type        = list(string)
  default     = []
}

variable "load_balancer_listener_arn" {
  description = "The arn of the load balancer listener where we will attach rules"
  type        = string
  default     = null
}

variable "load_balancer_associations" {
  description = "A jsonencoded map of maps, container name to lb target group and listener rule settings"
  type        = string
  default     = "{}"
}

variable "task_role" {
  description = "The jsonencoded IAM policy rules (i.e. iam-role) to associate with the ECS Fargate task"
  type        = string
  default     = "{}"
}

variable "kms_arns" {
  description = "A list of kms arns that this task needs to decrypt secrets"
  type        = list(string)
  default     = []
}

variable "log_retention_in_days" {
  description = "The number of days to retain logs streamed to the log group"
  type        = number
  default     = 365
}

variable "enable_execute_command" {
  description = "Whether to enable the ecs exec command for tasks within this service"
  type        = bool
  default     = true
}

variable "desired_count_map" {
  description = "map of counts for each service"
  type        = any
}

variable "deployment_maximum_percent" {
  description = "The percentage of (desired_count) tasks that can be running during deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "The percentage of (desired_count) running tasks for the service to be considered healthy"
  type        = number
  default     = 100
}

variable "health_check_grace_period_seconds" {
  description = "The time in seconds to ignore failing lb health checks on newly started tasks"
  type        = number
  default     = 60
}

variable "efs_subnets" {
  description = "The subnets in which any EFS volumes should be created (defaults to `subnets`)"
  type        = list(string)
  default     = null
}

variable "efs_volumes" {
  description = "A jsonencoded map of volume settings for provisioning an efs filesystem"
  type        = string
  default     = "{}"
}

variable "efs_volumes_backup_schedule" {
  description = "A CRON expression specifying when AWS Backup initiates a backup job (default: disabled)"
  type        = string
  default     = ""
}

variable "tags" {
  type        = map
  description = "A map of tags to apply to included resources"
  default     = {}
}
