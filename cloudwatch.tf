
#------------------------------------------------------------------------------
# Cloudwatch Loggroup 
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "demo_app" {
  depends_on = [aws_kms_key.kms_key_demo_app]

  name              = "/aws/lambda/${var.app_name}"
  retention_in_days = 7
  kms_key_id        = "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/${var.app_name}"

}

#------------------------------------------------------------------------------
# Cloudwatch Metric filters
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "lambda_error_messages" {
  name           = "errorMessages-lambda"
  pattern        = "{$.errorMessage = \"*result*\"}"
  log_group_name = aws_cloudwatch_log_group.demo_app.name

  metric_transformation {
    name      = "errorMessage-lambda-count"
    namespace = "myapp-namespace"
    value     = 1
  }
}

resource "aws_cloudwatch_log_metric_filter" "lambda_result" {
  name           = "lambda-result"
  pattern        = "{$.total = \"*\"}"
  log_group_name = aws_cloudwatch_log_group.demo_app.name

  metric_transformation {
    name      = "lambda-result-value"
    namespace = "myapp-namespace"
    value     = "$.total"
  }
}

#------------------------------------------------------------------------------
# Cloudwatch Metric Alarm
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "lambda_error_messages" {
  alarm_name          = "monitoring-lambda-error_messages"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = aws_cloudwatch_log_metric_filter.lambda_error_messages.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.lambda_error_messages.metric_transformation[0].namespace
  period              = "120"
  statistic           = "Sum"
  threshold           = 1
  datapoints_to_alarm = 2
  treat_missing_data  = "notBreaching"

  alarm_description = "Lambda error messages count - 2 datapoints within 6 minutes (3 periods)"

  alarm_actions = [aws_sns_topic.lambda_monitoring.arn]
  ok_actions    = [aws_sns_topic.lambda_monitoring.arn]
}


resource "aws_cloudwatch_metric_alarm" "lambda_results" {
  alarm_name          = "monitoring-lambda-results"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = aws_cloudwatch_log_metric_filter.lambda_result.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.lambda_result.metric_transformation[0].namespace
  period              = "120"
  statistic           = "Average"
  threshold           = 32
  datapoints_to_alarm = 2
  treat_missing_data  = "breaching"

  alarm_description = "Lambda results"

  alarm_actions = [aws_sns_topic.lambda_monitoring.arn]
  ok_actions    = [aws_sns_topic.lambda_monitoring.arn]
}



#------------------------------------------------------------------------------
# Cloudwatch Lambda scheduler
#------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "demo_app_schedule" {
  name                = "demo-app-schedule"
  description         = "Schedule for demo app"
  schedule_expression = "cron(* * * * ? *)"
}

resource "aws_cloudwatch_event_target" "demo_apps_trigger" {
  arn  = aws_lambda_function.myapp_lambda_function.arn
  rule = aws_cloudwatch_event_rule.demo_app_schedule.name
}

resource "aws_lambda_permission" "demo_app_trigger_permission" {
  statement_id  = "AllowCWEventTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myapp_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.demo_app_schedule.arn
}




