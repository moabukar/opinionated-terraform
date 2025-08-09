resource "aws_cloudwatch_log_group" "flow" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${aws_vpc.this.id}/flowlogs"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.flow[0].arn
  tags              = var.tags
}

resource "aws_kms_key" "flow" {
  count               = var.enable_flow_logs ? 1 : 0
  description         = "KMS for VPC flow logs"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_iam_role" "flow" {
  count              = var.enable_flow_logs ? 1 : 0
  name               = "${var.name}-flowlogs"
  assume_role_policy = data.aws_iam_policy_document.flow_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "flow_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "flow" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.name}-flowlogs"
  role  = aws_iam_role.flow[0].id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams"],
      Resource = "${aws_cloudwatch_log_group.flow[0].arn}:*"
    }]
  })
}

resource "aws_flow_log" "this" {
  count           = var.enable_flow_logs ? 1 : 0
  log_destination = aws_cloudwatch_log_group.flow[0].arn
  iam_role_arn    = aws_iam_role.flow[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
  destination_options {
    file_format        = "plain-text"
    per_hour_partition = true
  }
  tags = var.tags
}
