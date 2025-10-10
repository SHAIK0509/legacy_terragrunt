variable "application_name" {
  description = "The name of the application to deploy"
  type        = string
}

variable "environment" {
  description = "The name of the environment to deploy"
  type        = string
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
  default     = null
}

variable "min_capacity" {
  description = "min tasks"
  type        = number
  default     = null
}

variable "scale_target" {
  description = "cpu % to scale"
  type        = number
  default     = null
}

variable "container_definitions" {
  description = "A jsonencoded list of ECS Fargate container definitions"
  type        = string
}

variable "add_core_task_role_policy" {
  description = "Whether to inject access to parameters and secrets needed by Legacy's core module"
  type        = bool
  default     = false
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

variable "remote_state_paths" {
  description = "A map of names to paths relative to region/vpc-name"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
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

variable "log_retention_in_days" {
  description = "The number of days to retain logs streamed to the log group"
  type        = number
  default     = 365
}

variable "task_role" {
  description = "The jsonencoded IAM policy rules (i.e. iam-role) to associate with the ECS Fargate task"
  type        = string
  default     = "{}"
}

variable "ecs_cluster_name" {
  description = "The name of the ecs cluster that will host this application (default: the name of the shared cluster in this environment)"
  type        = string
  default     = ""
}

variable "create_ecs_cluster" {
  description = "Whether to create the ecs cluster with the given `cluster_name`"
  type        = bool
  default     = false
}

variable "enable_container_insights" {
  description = "If creating a new cluster, whether to enable container insights"
  type        = bool
  default     = false
}

variable "kms_arns" {
  description = "A list of kms arns that this task needs to decrypt secrets"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Whether to assign a public ip address to this service"
  type        = bool
  default     = false
}

variable "desired_count" {
  description = "The number of tasks that should be running as part of this service"
  type        = number
  default     = 1
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

variable "task_cpu" {
  description = "The CPU assignment for the ECS Fargate task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "The MEMORY assignment for the ECS Fargate task"
  type        = number
  default     = 512
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

variable "security_group_rules" {
  description = "A jsonencoded list of security group rules to associate with the service"
  default     = "[]"
}

variable "load_balancer_associations" {
  description = "A jsonencoded map of maps, container name to lb target group and listener rule settings"
  type        = string
  default     = "{}"
}

variable "create_route53_records" {
  description = "Whether to create route53 records from load balancer associations"
  type        = bool
  default     = false
}

variable "service_enable_execute_command" {
  description = "Whether to enable the ecs exec command for this service"
  type        = bool
  default     = true
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
  type        = map(string)
  description = "A map of custom tags to apply to the vpc and its related resources"
  default     = {}
}

variable "scheduled_tasks" {
  description = "Map of scheduled tasks"
  type        = map
  default     = {}
}

variable "gateways" {
  description = "Map of gateways"
  type        = map
  default     = {}
}
