resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = "sqs-queue-size-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when SQS queue has atleast 1 message"
  dimensions = {
    QueueName = aws_sqs_queue.background_jobs.name
  }

  alarm_actions = [aws_appautoscaling_policy.this.arn]
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = 1
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.background_workers.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  name               = "background-workers-scale-up-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 1.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "SQSQueueMessagesVisible"
    }
  }
}
