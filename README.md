# Terragrunt POC

POC to demonstrate using Terragrunt with [env0].

Be sure to read through [the Terragrunt documentation on DRY
Architectures](https://terragrunt.gruntwork.io/docs/features/keep-your-terragrunt-architecture-dry/)
to understand the features of Terragrunt used in this folder organization.

Note: This code is solely for demonstration purposes. This is not
production-ready code, so use at your own risk.

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

## How do you deploy the infrastructure with env0?

### Pre-requisites

1. [Create Your Organization](https://docs.env0.com/docs/create-your-organization)
1. [Connect Your VCS](https://docs.env0.com/docs/connect-your-vcs)
1. [Create Your Template](https://docs.env0.com/docs/create-your-first-template)

    Luckily, with Terragrunt, you don't have to repeat yourself and create a bunch of
    templates.  We were able to use a single template.

    For example:

    ```CONSOLE
    $ curl -s -H 'Accept: application/json' --user "${ENV0_USER}" "https://api.env0.com/blueprints/e48b07ed-883c-49da-92e2-5c5bf22c24e6" | yq e -P -
    # URL of the GitHub repo
    repository: https://github.com/nshenry03/terragrunt-live

    ...

    # Version of Terragrunt you want to use. We had trouble with the latest 0.36.7 so we just used 0.36.6
    terragruntVersion: 0.36.6

    # Branch or tag to use. Usually this would be main or master, but we are trying several solutions so we use the env0 branch
    revision: env0

    ...

    # The name you'd like to use for the template; it doesn't really matter too much what you call it
    name: Terragrunt

    # You can set these to whatever you want / need for your environment, they're empty for me
    retry: {}
    sshKeys: []

    ...

    # Version of Terraform you want to use
    terraformVersion: 1.1.9

    ...

    # Needs to be Terragrunt
    type: terragrunt

    ...
    ```

1. [Create Your Projects](https://docs.env0.com/docs/projects#create-a-new-project)

    We chose to create a project for each
    [account](## How is the code in this repo organized?) so we created
    `sandbox-apps` and `sandbox-sharedsvcs` projects.  You may want to create
    a project for each of your accounts or you may want to organize things
    differently. See the [Projects](https://docs.env0.com/docs/projects)
    documentation for more information.

    * You will need to follow the
      [Connect Your Cloud Account](https://docs.env0.com/docs/connect-your-cloud-account)
      instructions for each project
    * You will need to follow the
      [Associate Templates with a Project](https://docs.env0.com/docs/projects#associate-templates-with-a-project)
      instructions for each project to associate the "Terragrunt" template from before
      with each of your project.

### Deploying modules

Now that we've got everything setup, we can FINALLY start deploying
infrastructure! This is where it is fun to see the power of Terragrunt and env0
working together. For each project, you'll want to [Create an
Environment](https://docs.env0.com/docs/environments#create-an-environment) for
each of the resources that you need to deploy.  For this repository, we created
the following environments:

* Under project `sandbox-apps`:
  * `sandbox-apps/ap-southeast-1/sandbox/vpc`
  * `sandbox-apps/eu-west-1/sandbox/vpc`
  * `sandbox-apps/sa-east-1/sandbox/vpc`
* Under project `sandbox-sharedsvcs`:
  * `sandbox-sharedsvcs/ap-southeast-1/sandbox/vpc`
  * `sandbox-sharedsvcs/eu-west-1/sandbox/vpc`
  * `sandbox-sharedsvcs/sa-east-1/sandbox/vpc`

From the `Project Templates` page, click the `Run Now` button. We chose to keep
`Environment Name` and `Terragrunt Working Directory` the same (see list above),
but you're welcome to name your environments however works best for you.

[env0]: https://www.env0.com
