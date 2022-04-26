terraform {
  source = local.base_source_url
}

locals {
  # Expose the base source URL so different versions of the module can be deployed in different environments.
  base_source_url = "https://github.com/terraform-aws-modules/terraform-aws-vpc.git//.?ref=master"

  # Automatically load common variables
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  contact     = local.common_vars.locals.tag_contact
  customer    = local.account_vars.locals.tag_customer
  environment = local.account_vars.locals.tag_environment
  region      = local.region_vars.locals.tag_region

  account_cidr         = local.account_vars.locals.account_cidr
  account_type         = local.account_vars.locals.account_type
  aws_region           = local.region_vars.locals.aws_region
  cidr                 = cidrsubnet(local.account_cidr, 2, local.netnum)
  enable_dns_hostnames = local.account_vars.locals.vpc_enable_dns_hostnames
  enable_ipv6          = local.environment_vars.locals.vpc_enable_ipv6
  newbits              = local.account_type == "sharedsvcs" ? 4 : 7
  private_subnet_tags  = local.account_vars.locals.vpc_private_subnet_tags
  netnum               = lookup(local.common_vars.locals.vpc_netnum, local.aws_region)

  azs = [
    "${local.aws_region}a",
    "${local.aws_region}b",
    "${local.aws_region}c",
  ]

  tags = {
    Contact     = base64encode(local.contact)
    Customer    = local.customer
    Environment = local.environment
    Region      = local.region
  }
}

inputs = {
  name = "${local.environment}-${local.aws_region}-vpc"
  cidr = local.cidr
  azs  = local.azs

  enable_ipv6                     = local.enable_ipv6
  assign_ipv6_address_on_creation = local.enable_ipv6

  private_subnets = [
    cidrsubnet(local.cidr, local.newbits, 0),
    cidrsubnet(local.cidr, local.newbits, 2),
    cidrsubnet(local.cidr, local.newbits, 4),
    cidrsubnet(local.cidr, local.newbits, 6),
  ]

  private_subnet_ipv6_prefixes = local.enable_ipv6 ? [0, 1, 2, 3] : []
  private_subnet_tags          = local.private_subnet_tags

  public_subnets = [
    cidrsubnet(local.cidr, local.newbits, 1),
    cidrsubnet(local.cidr, local.newbits, 3),
    cidrsubnet(local.cidr, local.newbits, 5),
    cidrsubnet(local.cidr, local.newbits, 7),
  ]

  public_subnet_ipv6_prefixes = local.enable_ipv6 ? [4, 5, 6, 7] : []

  database_subnets = [
    cidrsubnet(local.cidr, local.newbits, 9),
    cidrsubnet(local.cidr, local.newbits, 11),
    cidrsubnet(local.cidr, local.newbits, 13),
    cidrsubnet(local.cidr, local.newbits, 15),
  ]

  database_subnet_ipv6_prefixes = local.enable_ipv6 ? [8, 9, 10, 11] : []

  elasticache_subnets = [
    cidrsubnet(local.cidr, local.newbits, 8),
    cidrsubnet(local.cidr, local.newbits, 10),
    cidrsubnet(local.cidr, local.newbits, 12),
    cidrsubnet(local.cidr, local.newbits, 14),
  ]

  elasticache_subnet_ipv6_prefixes = local.enable_ipv6 ? [12, 13, 14, 15] : []

  enable_dns_hostnames = local.enable_dns_hostnames

  tags = local.tags
}
