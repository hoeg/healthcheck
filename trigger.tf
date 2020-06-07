resource "aws_cloudwatch_event_rule" "rate_trigger" {
	name        = "scheduled-trigger"
	description = "Trigger every 15 minutes"

	schedule_expression = "rate(15 minutes)"
}
