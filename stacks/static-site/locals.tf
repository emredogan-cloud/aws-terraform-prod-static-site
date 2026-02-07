locals {
  prefix = "${var.project}-${var.env}"

  common_tags = merge(var.tags, { Project = var.project, Env = var.env, ManagedBy = "Terraform" })
}
