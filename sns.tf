
resource "aws_sns_topic" "lambda_monitoring" {
  depends_on = [aws_kms_key.kms_key_demo_app]

  name              = "lambda-monitoring"
  kms_master_key_id = "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/${var.app_name}"
}

resource "aws_sns_topic_policy" "lambda_monitoring_policy" {
  arn    = aws_sns_topic.lambda_monitoring.arn
  policy = data.aws_iam_policy_document.lambda_monitoring_policy_document.json
}

data "aws_iam_policy_document" "lambda_monitoring_policy_document" {
  statement {
    sid    = "CloudwatchAccess"
    effect = "Allow"
    actions = [
      "SNS:Publish",
    ]
    resources = [
      aws_sns_topic.lambda_monitoring.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }

  statement {
    sid    = "DefaultAccountAccess"
    effect = "Allow"
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish"
    ]
    resources = [
      aws_sns_topic.lambda_monitoring.arn
    ]

    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceOwner"
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
