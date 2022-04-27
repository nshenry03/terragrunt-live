locals {
  # Automatically load common variables
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  aws_account_id = local.account_vars.locals.aws_account_id
  aws_region     = local.region_vars.locals.aws_region
  environment    = local.account_vars.locals.tag_environment
  account        = "${split("-", local.environment)[0]}-${split("-", local.environment)[1]}"

  tfc_hostname     = "app.terraform.io"
  tfc_organization = "sebu-edgeops"
  workspace        = reverse(split("/", get_terragrunt_dir()))[0] # This will find the name of the module, such as "vpc"
  workspace_name   = "${local.account}-${local.aws_region}-${local.workspace}"
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.aws_account_id}"]
}
EOF
}

# Generate backend
generate "remote_state" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "remote" {
    hostname = "${local.tfc_hostname}"
    organization = "${local.tfc_organization}"

    workspaces {
      name = "${local.workspace_name}"
    }
  }
}
EOF
}

# # Generate creds
# generate "aws_creds" {
#   path      = "aws_creds.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<EOF
# data "tfe_organization" "this" {
#   name = "${local.tfc_organization}"
# }
#
# resource "tfe_workspace" "this" {
#   name         = "${local.workspace_name}"
#   organization = data.tfe_organization.this.name
# }
#
# resource "tfe_variable" "aws_access_key_id" {
#   key          = "AWS_ACCESS_KEY_ID"
#   value        = "${get_env("AWS_ACCESS_KEY_ID", "wrong")}"
#   category     = "env"
#   workspace_id = tfe_workspace.this.id
#   description  = "Specifies an AWS access key associated with an IAM user or role."
#   sensitive    = true
# }
#
# resource "tfe_variable" "aws_secret_access_key" {
#   key          = "AWS_SECRET_ACCESS_KEY"
#   value        = "${get_env("AWS_SECRET_ACCESS_KEY", "wrong")}"
#   category     = "env"
#   workspace_id = tfe_workspace.this.id
#   description  = "Specifies the secret key associated with the access key. This is essentially the 'password' for the access key."
#   sensitive    = true
# }
#
# resource "tfe_variable" "aws_session_token" {
#   key          = "AWS_SESSION_TOKEN"
#   value        = "${get_env("AWS_SESSION_TOKEN", "wrong")}"
#   category     = "env"
#   workspace_id = tfe_workspace.this.id
#   description  = "Specifies the session token value that is required if you are using temporary security credentials that you retrieved directly from AWS STS operations."
#   sensitive    = true
# }
# EOF
# }

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
  local.common_vars.locals,
)
