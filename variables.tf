# Terraform variables file

variable "name" {
  description = "Define name to use for lambda function, cloudwatch event and iam role"
  type        = string
}

variable "custom_iam_role_arn" {
  description = "Custom IAM role arn for the scheduling lambda"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "The ARN for the KMS encryption key. If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key."
  type        = string
  default     = null
}

variable "tags" {
  description = "Custom tags on aws resources"
  type        = map(any)
  default     = null
}

variable "schedules_definitions" {
  description = "Schedules definitions to be used in Lambda funcion"
  type = list(object({
    name                           = string
    aws_regions                    = list(string)
    cloudwatch_schedule_expression = string
    schedule_action                = string
    autoscaling_schedule           = string
    ec2_schedule                   = string
    rds_schedule                   = string
    cloudwatch_alarm_schedule      = string
    scheduler_tag = object({
      key   = string
      value = string
    })
  }))
  # aws_regions: A list of one or more aws regions where the lambda will be apply	
  # cloudwatch_schedule_expression: Define the aws cloudwatch event rule schedule expression (https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html)
  # schedule_action: Define schedule action to apply on resources, accepted value are 'stop or 'start
  # autoscaling_schedule: Enable scheduling on autoscaling resources
  # ec2_schedule: Enable scheduling on ec2 resources
  # rds_schedule: Enable scheduling on rds resources
  # cloudwatch_alarm_schedule: Enable scheduleding on cloudwatch alarm resources
  # scheduler_tag: Set the tag to use for identify aws resources to stop or start
}