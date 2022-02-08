# -*- coding: utf-8 -*-

"""This script stop and start aws resources."""
import os
from distutils.util import strtobool

from scheduler.autoscaling_handler import AutoscalingScheduler
from scheduler.cloudwatch_handler import CloudWatchAlarmScheduler
from scheduler.instance_handler import InstanceScheduler
from scheduler.rds_handler import RdsScheduler


def lambda_handler(event, context):
    """Main function entrypoint for lambda.

    Stop and start AWS resources:
    - rds instances
    - rds aurora clusters
    - instance ec2

    Suspend and resume AWS resources:
    - ec2 autoscaling groups

    Terminate spot instances (spot instance cannot be stopped by a user)
    """
    # Retrieve variables from aws lambda ENVIRONMENT
    schedule_action = event["schedule_action"]
    aws_regions = event["aws_regions"]
    format_tags = [{"Key": event["scheduler_tag"]["key"], "Values": [event["scheduler_tag"]["value"]]}]

    _strategy = {}
    _strategy[AutoscalingScheduler] = event["autoscaling_schedule"]
    _strategy[InstanceScheduler] = event["ec2_schedule"]
    _strategy[RdsScheduler] = event["rds_schedule"]
    _strategy[CloudWatchAlarmScheduler] = event["cloudwatch_alarm_schedule"]

    for service, to_schedule in _strategy.items():
        if strtobool(to_schedule):
            for aws_region in aws_regions:
                strategy = service(aws_region)
                getattr(strategy, schedule_action)(aws_tags=format_tags)
