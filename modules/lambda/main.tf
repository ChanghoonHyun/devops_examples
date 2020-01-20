data "archive_file" "zip" {
  type = "zip"
  source_file = var.source_file
  output_path = var.output_path
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid = ""
    effect = "Allow"

    principals {
      identifiers = [
        "lambda.amazonaws.com"]
      type = "Service"
    }

    actions = [
      "sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}

resource "aws_lambda_function" "lambda" {
  function_name = var.function_name

  filename = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  role = aws_iam_role.iam_for_lambda.arn
  handler = var.handler
  runtime = var.runtime
}
