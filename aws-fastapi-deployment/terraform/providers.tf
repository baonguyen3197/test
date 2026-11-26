provider "aws" {
  region              = var.region
  allowed_account_ids = var.aws_account_id == null ? null : [var.aws_account_id]

  default_tags {
    tags = merge(
      {
        Project   = var.name
        ManagedBy = "Terraform"
      },
      var.tags
    )
  }
}
