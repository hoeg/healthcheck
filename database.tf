resource "aws_dynamodb_table" "healthcheck" {
	name = "Healthcheck"
	hash_key = "id"

	attribute {
		name = "id"
		type = "S"
	}
}

resource "aws_dynamodb_table_item" "targets" {
	table_name = ${aws_dynamodb_table.healthcheck.name}
	hash_key   = ${aws_dynamodb_table.healthcheck.hash_key}

	item = <<ITEM
	{
		"id": {"S": "targets"},
		"hosts": []
	}
ITEM
}

resource "aws_dynamodb_table_item" "unhealthy" {
	table_name = ${aws_dynamodb_table.healthcheck.name}
	hash_key   = ${aws_dynamodb_table.healthcheck.hash_key}

	item = <<ITEM
	{
		"id": {"S": "unhealthy"},
		"hosts": []
	}
ITEM
}
