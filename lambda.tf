resource "aws_lambda_permission" "allow_cloudwatch_trigger" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = ${aws_lambda_function.healthcheck.function_name}
  principal     = "events.amazonaws.com"
  source_arn    = ${aws_cloudwatch_event_rule.rate_trigger.arn}
  qualifier     = ${aws_lambda_alias.healthcheck_alias.name}
}

resource "aws_lambda_alias" "healthcheck_alias" {
  name             = "healthcheck"
  description      = "Call all health endpoints on registered targets and notify if any fails."
  function_name    = "${aws_lambda_function.healthcheck.function_name}"
  function_version = "$LATEST"
}

data "archive_file" "source" {
  type        = "zip"
  source_dir = "${path.module}/src/"
  output_path = "${path.module}/src.zip"
}

resource "aws_lambda_function" "healthcheck" {
	filename      = ${data.archive_file.source.output_path}
	function_name = "healthcheck"
	role          = "${aws_iam_role.iam_for_lambda.arn}"
	handler       = "healthcheck.check"
	runtime       = "python3.7"

	environment {
		variables = {
			TOKEN_PATH = ${aws_ssm_parameter.secret.name}
		}
	}
}

resource "aws_iam_policy" "lambda_permission" {
  name        = "healthcheck-permissions"
  description = "Permissions needed to de healthchecks"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"dynamodb:BatchGetItem",
				"dynamodb:GetItem",
				"dynamodb:Query",
				"dynamodb:Scan",
				"dynamodb:BatchWriteItem",
				"dynamodb:PutItem",
				"dynamodb:UpdateItem"
			],
			"Effect": "Allow",
			"Resource": ${aws_dynamodb_table.healthcheck.arn} 
		},
		{
			"Action": [
				"ssm:GetParameters"
			],
			"Effect": "Allow",
			"Resource": ${aws_ssm_parameter.secret.arn}
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_lambda" {
  role       = ${aws_iam_role.healthcheck.name}
  policy_arn = ${aws_iam_policy.lambda_permission.arn}
}

resource "aws_iam_role" "healthcheck" {
  name = "execute_healthcheck"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
