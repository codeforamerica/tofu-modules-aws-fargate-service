module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.8.0"

  for_each = var.volumes

  name = "${local.prefix}-${each.key}"
  encrypted = true
  kms_key_arn = aws_kms_key.fargate.arn
  security_group_use_name_prefix = true
  security_group_vpc_id = var.vpc_id
  security_group_rules = {
    service = {
      description = "Allow access to the volume from the service."
      source_security_group_id = module.task_security_group.security_group_id
    }
  }
  mount_targets = {
    for subnet in var.private_subnets : subnet => {
      subnet_id = subnet
    }
  }

  tags = var.tags
}
