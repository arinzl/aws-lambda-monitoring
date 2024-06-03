resource "aws_kms_key" "kms_key_demo_app" {
  description = "KMS for SNS topic and cloudwatch logs"
  policy      = data.aws_iam_policy_document.kms_policy_demo_app.json

  enable_key_rotation = true
}

resource "aws_kms_alias" "kms_alias_demo_appc" {
  name          = "alias/${var.app_name}"
  target_key_id = aws_kms_key.kms_key_demo_app.id
}

data "aws_iam_policy_document" "kms_policy_demo_app" {

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = [
      "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/*"
    ]
  }
  statement {
    sid    = "Allow key usage for SNS topics"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:sns:arn"

      values = ["arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:*"]

    }
  }

  statement {
    sid    = "Allow CloudWatch Alarms Access to SNS topics"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com"
      ]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["sns.ap-southeast-2.amazonaws.com"]
    }
  }

  statement {
    sid    = "Allow cross account key usage for CloudWatch Logs"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "logs.${var.region}.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*"]

    }
  }
}
