variable "environment" {
  description = "environment"
  type        = string
}

variable "token" {
  description = "internal token"
  type        = string
}

variable "api_name" {
  description = "api name"
  type        = string
}

variable "invoke_url" {
  description = "url for api"
  type        = string
}

variable "set_params_for" {
  description = "what apps to set params and secrets for"
  type        = list
}
