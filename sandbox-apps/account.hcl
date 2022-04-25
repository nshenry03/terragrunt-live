# Set account-wide variables. These are automatically pulled in to configure the
# remote state bucket in the root terragrunt.hcl configuration.
locals {
  account_cidr    = "10.202.0.0/17"
  aws_account_id  = "481862586350"
  tag_environment = "sandbox-apps"

  # Calculated
  account_type             = split("-", local.tag_environment)[1] == "apps" ? "apps" : "sharedsvcs"
  tag_customer             = title(split("-", local.tag_environment)[0])
  vpc_enable_dns_hostnames = local.account_type == "sharedsvcs" ? true : false

  vpc_private_subnet_tags = (
    local.account_type == "sharedsvcs"
    ? { "kubernetes.io/role/internal-elb" = 1 }
    : {}
  )
}
