resource "aws_ssm_parameter" "secret" {
  name        = "/healthcheck/token"
  description = "Token used for nofying errors in healthcheck"
  type        = "SecureString"
  value       = "${var.token}"
}
