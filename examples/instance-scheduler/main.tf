# Terraform ec2 instance with lambda scheduler
data "aws_region" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "scheduled" {
  count         = "3"
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
    tostop        = "true"
    terratest_tag = var.random_tag
  }
}

resource "aws_instance" "not_scheduled" {
  count         = "2"
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
    tostop        = "false"
    terratest_tag = var.random_tag
  }
}


### Terraform modules ###
module "ec2-stop-start" {
  source = "../../"
  name   = "ec2-stop-start"
  schedules = [
    {
      name                           = "stop-friday-23"
      aws_regions                    = ["us-east-2"]
      cloudwatch_schedule_expression = "cron(0 23 ? * FRI *)"
      schedule_action                = "stop"
      autoscaling_schedule           = "false"
      ec2_schedule                   = "true"
      rds_schedule                   = "false"
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
      autoscaling_schedule           = "false"
      ec2_schedule                   = "true"
      rds_schedule                   = "false"
      cloudwatch_alarm_schedule      = "true"
      scheduler_tag = {
        key   = "tostop"
        value = "true"
      } 
    },
  ]
}
