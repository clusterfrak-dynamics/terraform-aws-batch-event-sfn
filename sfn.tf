data "aws_iam_policy_document" "batch_sfn_state_machine_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "states.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "batch_sfn_state_machine_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      var.create_sns_topic ? join("", aws_sns_topic.batch_cfn_sns_topic.*.arn) : var.sns_topic_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "batch:SubmitJob",
      "batch:DescribeJobs",
      "batch:TerminateJob"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = [
      "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForBatchJobsRule"
    ]
  }
}

resource "aws_iam_role" "batch_sfn_state_machine" {
  name               = "${var.name}-sfn"
  assume_role_policy = data.aws_iam_policy_document.batch_sfn_state_machine_assume_role_policy.json
  tags     = var.tags
}

resource "aws_iam_policy" "batch_sfn_state_machine" {
  name   = "${var.name}-sfn"
  policy = data.aws_iam_policy_document.batch_sfn_state_machine_policy.json
}

resource "aws_iam_role_policy_attachment" "batch_sfn_state_machine" {
  role       = aws_iam_role.batch_sfn_state_machine.name
  policy_arn = aws_iam_policy.batch_sfn_state_machine.arn
}

resource "aws_sfn_state_machine" "batch_sfn_state_machine" {
  name     = var.name
  role_arn = aws_iam_role.batch_sfn_state_machine.arn
  tags     = var.tags

  definition = <<EOF
{
  "Comment": "${var.sfn_comment}",
  "StartAt": "Submit Batch Job",
  "TimeoutSeconds": 3600,
  "States": {
    "Submit Batch Job": {
      "Type": "Task",
      "Resource": "arn:aws:states:::batch:submitJob.sync",
      "Parameters": {
        "JobName": "${var.job_name}",
        "JobQueue": "${var.job_queue}",
        "JobDefinition": "${aws_batch_job_definition.this.arn}"
      },
      "End": true,
      "Catch": [
          {
            "ErrorEquals": [ "States.ALL" ],
            "Next": "Notify Failure"
          }
      ]
    },
    "Notify Failure": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": "${var.sfn_failure_message}",
        "TopicArn": "${var.create_sns_topic ? join("", aws_sns_topic.batch_cfn_sns_topic.*.arn) : var.sns_topic_arn}"
      },
      "End": true
    }
  }
}
EOF
}
