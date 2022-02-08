# Terraform AWS Lambda - Start and Stop EC2 instances, Autoscaling Groups and RDS in a schedule

This repository contains the Terraform definition to create some resources to allow stop and start EC2 instances, RDS resources and autoscaling groups with lambda function through a schedule

## Terraform versions
Terraform 0.15

## UTC Timezone
It is important to know that this project is configured to use [UTC Timezone](https://time.is/UTC), so all CRON expressions will execute considering this timezone. 

## Features

*  AWS lambda runtine Python 3.7
*  EC2 instances scheduling
*  RDS clusters scheduling
*  RDS instances scheduling
*  Autoscalings scheduling
*  Cloudwatch alarm scheduling
*  AWS CloudWatch logs for lambda

## Usage and Examples

#### 1. Stop EC2 instances everyday at 7pm (UTC) that have a tag named "Schedule" with the value "stop-everyday-7pm" 
```hcl
module "schedule_ec2" {
  source = "./terraform-aws-lambda-scheduler-stop-start-master/"
  name   = "ec2-scheduler"
  schedules = [
    {
      name                           = "stop-everyday-07pm"
      aws_regions                    = ["us-east-2"]
      cloudwatch_schedule_expression = "cron(00 19 * * ? *)"
      schedule_action                = "stop"
      autoscaling_schedule           = "false"
      ec2_schedule                   = "true"
      rds_schedule                   = "false"
      cloudwatch_alarm_schedule      = "false"
      scheduler_tag = {
        key   = "Schedule"
        value = "stop-everyday-7pm"
      } 
    },
  ]
}
```

#### 2. Start auto-scaling groups and RDS instances on weekdays at 7am (UTC) and stop them everyday at 8pm (UTC), having a Tag named "Schedule" with the value "mon-fri-7-19"
```hcl
module "schedule_ec2_rds" {
  source = "./terraform-aws-lambda-ec2-rds-scheduler"
  name   = "ec2-rds-scheduler"
  schedules = [
    {
      name                           = "start-weekdays-07am"
      aws_regions                    = ["us-east-2"]
      cloudwatch_schedule_expression = "cron(00 07 * * 1-5 *)"
      schedule_action                = "start"
      autoscaling_schedule           = "true"
      ec2_schedule                   = "true"
      rds_schedule                   = "true"
      cloudwatch_alarm_schedule      = "false"
      scheduler_tag = {
        key   = "Schedule"
        value = "mon-fri-7-19"
      } 
    },
    {
      name                           = "stop-daily-07pm"
      aws_regions                    = ["us-east-2"]
      cloudwatch_schedule_expression = "cron(00 19 * * ? *)"
      schedule_action                = "stop"
      autoscaling_schedule           = "true"
      ec2_schedule                   = "true"
      rds_schedule                   = "true"
      cloudwatch_alarm_schedule      = "false"
      scheduler_tag = {
        key   = "Schedule"
        value = "mon-fri-7-19"
      } 
    },
  ]
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Define name to use for lambda function, cloudwatch event and iam role | string | n/a | yes |
| custom_iam_role_arn | Custom IAM role arn for the scheduling lambda. If  | string | null | no |
| tags | Custom tags on AWS resources | map | null | no |
| kms_key_arn | The ARN for the KMS encryption key. If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key | string | null | no |
| schedules_definitions | A list of objects containing the Event Rule definitions | list(object) | null | yes |
| schedules_definitions.name |  The name of the schedule | string | null | yes |
| schedules_definitions.aws_regions |  A list of one or more AWS regions where the lambda will be apply | list(string) | null | yes |
| schedules_definitions.cloudwatch_schedule_expression | The scheduling expression | string | null | yes |
| schedules_definitions.autoscaling_schedule | Enable scheduling on autoscaling resources | string | null | yes |
| schedules_definitions.ec2_schedule | Enable scheduling on EC2 instance resources | string | null | yes |
| schedules_definitions.rds_schedule | Enable scheduling on RDS resources | string | null | yes |
| schedules_definitions.cloudwatch_alarm_schedule | Enable scheduleding on cloudwatch alarm resources | string | null | yes |
| schedules_definitions.schedule_action | Define schedule action to apply on resources | string | null | yes |
| schedules_definitions.scheduler_tag | Set the tag to use for identify AWS resources to stop or start | map | null | yes |

## Outputs

| Name | Description |
|------|-------------|
| lambda_iam_role_arn | The ARN of the IAM role used by Lambda function |
| lambda_iam_role_name | The name of the IAM role used by Lambda function |
| scheduler_lambda_arn | The ARN of the Lambda function |
| scheduler_lambda_name | The name of the Lambda function |
| scheduler_lambda_invoke_arn | The ARN to be used for invoking Lambda function from API Gateway |
| scheduler_lambda_function_last_modified | The date Lambda function was last modified |
| scheduler_lambda_function_version | Latest published version of your Lambda function |
| scheduler_log_group_name | The name of the scheduler log group |
| scheduler_log_group_arn | The Amazon Resource Name (ARN) specifying the log group |

## Tests

Some of these tests create real resources in an AWS account. That means they cost money to run, especially if you don't clean up after yourself. Please be considerate of the resources you create and take extra care to clean everything up when you're done!

In order to run tests that access your AWS account, you will need to configure your [AWS CLI
credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html). For example, you could
set the credentials as the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

### Integration tests

Integration tests are realized with python `boto3` and `pytest` modules.

Install Python dependency:

```shell
python3 -m pip install -r requirements-dev.txt
```

```shell
# Test python code use by instance scheduler scheduler
python3 -m pytest -n 4 --cov=package tests/integration/test_instance_scheduler.py

# Test python code use by autoscaling scheduler
python3 -m pytest -n 4 --cov=package tests/integration/test_asg_scheduler.py

# Test python code use by rds scheduler
python3 -m pytest -n 8 --cov=package tests/integration/test_rds_scheduler.py

# Test pythn code use by cloudwatch alarm scheduler
python3 -m pytest -n 12 --cov=package tests/integration/test_cloudwatch_alarm_scheduler.py

# Test all python code
python3 -m pytest -n 30 --cov=package tests/integration/
```

### End-to-end tests

This module has been packaged with [Terratest](https://github.com/gruntwork-io/terratest) to tests this Terraform module.

Install Terratest with depedencies:

```shell
# Prerequisite: install Go
go get ./...
```

```shell
# Test instance scheduler
go test -timeout 900s -v tests/end-to-end/instance_scheduler_test.go

# Test autoscaling scheduler
go test -timeout 900s -v tests/end-to-end/autoscaling_scheduler_test.go
```

## Authors

Modules forked: [diodonfrost](https://github.com/diodonfrost/terraform-aws-lambda-scheduler-stop-start).
The code has been changed to dynamically create Amazon EventBridge Rules (CloudWatch Event Rule).

## Licence

Apache 2 Licensed. See LICENSE for full details.

## Resources

*   [Cloudwatch Schedule Expressions](https://docs.AWS.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html)
*   [Python boto3 EC2](https://boto3.amazonAWS.com/v1/documentation/api/latest/reference/services/EC2.html)
*   [Python boto3 RDS](https://boto3.amazonAWS.com/v1/documentation/api/latest/reference/services/RDS.html)
*   [Python boto3 autoscaling](https://boto3.amazonAWS.com/v1/documentation/api/latest/reference/services/autoscaling.html)
