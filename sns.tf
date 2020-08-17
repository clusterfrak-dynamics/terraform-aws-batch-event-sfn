locals {
  enabled_sns_topic = var.create_sns_topic ? 1 : 0
}

resource "aws_sns_topic" "batch_cfn_sns_topic" {
  count = local.enabled_sns_topic
  name  = var.name
  tags  = var.tags
}
