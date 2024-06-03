resource "aws_lambda_function" "myapp_lambda_function" {
  filename      = "${path.module}/appfolder_out/myapp.zip"
  function_name = var.app_name
  role          = aws_iam_role.lambda.arn
  handler       = "myapp.lambda_handler"
  runtime       = "python3.12"
}



