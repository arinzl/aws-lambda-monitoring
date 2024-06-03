data "aws_caller_identity" "current" {}

data "archive_file" "zip_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/appfolder/"
  output_path = "${path.module}/appfolder_out/myapp.zip"
}
