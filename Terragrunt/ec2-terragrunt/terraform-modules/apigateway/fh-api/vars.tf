variable "environment" {
  type        = string
  default     = "https://registry.terraform.io/modules/clouddrove/api-gateway/aws"
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "connection_type" {
  type        = string
  default     = null
  description = "string of connectiont type"
}

variable "connection_id" {
  type        = string
  default     = null
  description = "string of connection id"
}

variable "stage_name" {
  type        = string
  default     = null
  description = "stage name"
}

variable "stage_name_two" {
  type        = string
  default     = null
  description = "second stage name"
}

variable "connection_uri" {
  type        = string
  default     = null
  description = "string of connection uri"
}

variable "connection_uri_two" {
  type        = string
  default     = null
  description = "second string of connection uri"
}

variable "connection_uri_three" {
  type        = string
  default     = null
  description = "string of connection uri"
}

variable "connection_uri_four" {
  type        = string
  default     = null
  description = "string of connection uri"
}

variable "burst_limit" {
  type        = number
  default     = null
  description = "value for burst limit in usage plan"
}

variable "rate_limit" {
  type        = number
  default     = null
  description = "value for rate limit in usage plan"
}

variable "adn_key" {
  type        = string
  default     = null
  description = "id of the adn key in aws"
}

variable "adpay_key" {
  type        = string
  default     = null
  description = "id of the adpay key in aws"
}

variable "ipublish_key" {
  type        = string
  default     = null
  description = "id of the ipublish key in aws"
}

variable "services_domain" {
  type        = string
  default     = null
  description = "string of the services domain"
}
