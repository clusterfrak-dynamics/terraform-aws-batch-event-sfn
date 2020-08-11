data "aws_iam_policy_document" "ecs_batch_job_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "ecs_batch_job_role" {
  name               = "${var.name}-batch-job"
  assume_role_policy = data.aws_iam_policy_document.ecs_batch_job_assume_policy.json
  path               = var.iam_path
  tags               = merge({ "Name" = "${var.name}-batch-job" }, var.tags)
}

resource "aws_batch_job_definition" "this" {
  name                 = "${var.name}-batch-job-def"
  type                 = "container"
  container_properties = <<CONTAINER_PROPERTIES
{
    "command": ${jsonencode(var.container_command)},
    "image": "${var.container_image}",
    "jobRoleArn": "${aws_iam_role.ecs_batch_job_role.arn}",
    "memory": ${var.container_memory},
    "vcpus": ${var.container_vcpus},
    "environment": ${jsonencode(var.container_environment)}
}
CONTAINER_PROPERTIES
}
