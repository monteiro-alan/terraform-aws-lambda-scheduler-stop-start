# Deploy two lambda for testing with awspec

resource "aws_kms_key" "scheduler" {
  description             = "test kms option on scheduler module"
  deletion_window_in_days = 7
}

module "stop-start" {
  source = "../../"
  name   = "stop-start"
  schedules = [
    {
      name                           = "stop-friday-23"
      aws_regions                    = ["us-east-2"]
      cloudwatch_schedule_expression = "cron(0 23 ? * FRI *)"
      schedule_action                = "stop"
      autoscaling_schedule           = "true"
      ec2_schedule                   = "true"
      rds_schedule                   = "true"
      cloudwatch_alarm_schedule      = "true"
      scheduler_tag = {
        key   = "tostop"
        value = "true"
      } 
    },
    {
      name                           = "start-monday-7"
      aws_regions                    = ["us-east-2"]
      cloudwatch_schedule_expression = "cron(0 07 ? * MON *)"
      schedule_action                = "start"
      autoscaling_schedule           = "true"
      ec2_schedule                   = "true"
      rds_schedule                   = "true"
      cloudwatch_alarm_schedule      = "true"
      scheduler_tag = {
        key   = "tostop"
        value = "true"
      } 
    },
  ]
}