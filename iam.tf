
resource "aws_iam_role" "lambda" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole",
                "Effect": "Allow"
            }
        ]
    }
    EOF
}


resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "${var.app_name}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "LambdaCloudwatchGroup",
              "Effect": "Allow",
              "Action": "logs:CreateLogGroup",
              "Resource": "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:*"
          },
          {
              "Sid": "LambdaCloudwatchLogging",
              "Effect": "Allow",
              "Action": [
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
              ],
              "Resource": "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.app_name}:*"
          }
      ]
    }
    EOF
}
