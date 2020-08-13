data "aws_iam_policy_document" "batch_events_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "batch_events_policy" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.batch_sfn_state_machine.arn
    ]
  }
}

resource "aws_iam_policy" "batch_events" {
  name   = "${var.name}-event"
  policy = data.aws_iam_policy_document.batch_events_policy.json
  path   = var.iam_path
}

resource "aws_iam_role" "batch_events" {
  name               = "${var.name}-event"
  assume_role_policy = data.aws_iam_policy_document.batch_events_assume_role_policy.json
  path               = var.iam_path
  tags               = merge({ "Name" = "${var.name}-event" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "ecs_events" {
  role       = aws_iam_role.batch_events.name
  policy_arn = aws_iam_policy.batch_events.arn
}

resource "aws_cloudwatch_event_rule" "default" {
  name                = var.name
  event_pattern       = var.event_pattern
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "default" {
  target_id = var.name
  arn       = aws_sfn_state_machine.batch_sfn_state_machine.arn
  rule      = aws_cloudwatch_event_rule.default.name
  role_arn  = aws_iam_role.batch_events.arn
}
