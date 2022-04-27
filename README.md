# Terragrunt POC

POC to demonstrate using Terragrunt with [Terraform Cloud].

Be sure to read through [the Terragrunt documentation on DRY
Architectures](https://terragrunt.gruntwork.io/docs/features/keep-your-terragrunt-architecture-dry/)
to understand the features of Terragrunt used in this folder organization.

Note: This code is solely for demonstration purposes. This is not
production-ready code, so use at your own risk.

## How do you deploy the infrastructure in this repo?

### Pre-requisites

1. Install [`tfenv`](https://github.com/tfutils/tfenv) and
   [`tgenv`](https://github.com/cunymatthieu/tgenv`).
1. Install [Terraform](https://www.terraform.io/) with `tfenv install` and
   [Terragrunt](https://github.com/gruntwork-io/terragrunt) with `tgenv
   install`.
1. Export `TG_BUCKET_PREFIX` to something unique; for example: `export
   TG_BUCKET_PREFIX=nshenry03`

### Deploying a single module

1. `cd` into the module's folder (e.g.
   `cd sandbox-apps/us-west-2/sandbox/vpc`).
1. Run `terragrunt plan` to see the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply`.

### Deploying all modules in a region

1. `cd` into the region folder (e.g.
   `cd sandbox-apps/us-west-2`).
1. Run `terragrunt run-all plan` to see all the changes you're about to apply.
1. If the plan looks good, run `terragrunt run-all apply`.

## How is the code in this repo organized?

The code in this repo uses the following folder hierarchy:

```NOFORMAT
account
 └ _global
 └ region
    └ _global
    └ environment
       └ resource
```

Where:

* **Account**: At the top level are each of your AWS accounts, such as
  `stage-account`, `prod-account`, `mgmt-account`, etc. If you have everything
  deployed in a single AWS account, there will just be a single folder at the
  root (e.g. `main-account`).
* **Region**: Within each account, there will be one or more [AWS
  regions](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html),
  such as `us-east-1`, `eu-west-1`, and `ap-southeast-2`, where you've deployed
  resources. There may also be a `_global` folder that defines resources that
  are available across all the AWS regions in this account, such as IAM users,
  Route 53 hosted zones, and CloudTrail.
* **Environment**: Within each region, there will be one or more "environments",
  such as `qa`, `stage`, etc. Typically, an environment will correspond to a
  single [AWS Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc/), which
  isolates that environment from everything else in that AWS account. There may
  also be a `_global` folder that defines resources that are available across
  all the environments in this AWS region, such as Route 53 A records, SNS
  topics, and ECR repos.
* **Resource**: Within each environment, you deploy all the resources for that
  environment, such as EC2 Instances, Auto Scaling Groups, ECS Clusters,
  Databases, Load Balancers, and so on.

## Creating and using root (account) level variables

In the situation where you have multiple AWS accounts or regions, you often have
to pass common variables down to each of your modules. Rather than copy/pasting
the same variables into each `terragrunt.hcl` file, in every region, and in
every environment, you can inherit them from the `inputs` defined in the root
`terragrunt.hcl` file.

[Terraform Cloud]: https://app.terraform.io
