variable "name" {
  type        = string
  description = "The name of ecs task definition."
}

variable "container_command" {
  type    = list
  default = []
}

variable "container_memory" {}

variable "container_vcpus" {}

variable "container_image" {}

variable "container_environment" {
  type    = list
  default = []
}

variable "job_name" {}

variable "job_queue" {}

variable "sfn_comment" {
  default = "An example of the Amazon States Language for notification on an AWS Batch job completion"
}

variable "sfn_success_message" {
  default = "batch job submitted through step functions succeeded"
}

variable "sfn_failure_message" {
  default = "batch job submitted through step functions failed"
}

variable "iam_path" {
  default     = "/"
  type        = string
  description = "Path in which to create the IAM Role and the IAM Policy."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}

variable "create_sns_topic" {
  default     = true
  type        = string
  description = "Specify true to enable creation of SNS topic"
}

variable "sns_topic_arn" {
  default     = ""
  type        = string
  description = "Specify the SNS topic ARN"
}

variable "schedule_expression" {
  default = null
}

variable "event_pattern" {
  default = null
}
