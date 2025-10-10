#vars
variable "app_name" {
  description = "name of app"
  type        = string
}

variable "external_users" {
  description = "map of users and options"
  type = map(object({
    burst_limit = number
    rate_limit  = number
  }))
}

variable "api_id" {
  description = "api id"
  type        = string
}

variable "stage_name" {
  description = "stage name"
  type        = string
}

