# How to Use This: Provisioning and Managing This Project's Azure Deployments with Terraform

## Setup

Install the Azure command-line interface tool known as `az`. On MacOS:

    brew install az

Install terraform. On MacOS:

    brew install terraform

## Authorizing the `az` CLI

To allow terraform to connect to the Cloud City owned Azure environment, you will need to `az login` and then log in to your Cloud City Microsoft account. It will probably have a username like `first.last@cloudcity.io`.

To terraform the WHO owned Azure environment, you will need to `az login`, choose the "Sign-in options" choice at the bottom of the login form, choose "Sign in to an organization", and then enter the domain name "worldhealthorg.onmicrosoft.com". After that, you can log in using your WHO account, which will probably be your Cloud City email address.

It should (theoretically) be possible to sign in to both accounts at the same time, and have terraform interact with the correct Azure subscription.

## Directory layout

You will find different folders in `config/terraform/env` for the different
places that this app can be deployed. This uses the "main module pattern" to
avoid duplication and avoid state file conflicts.

Since each env directory contains its own state we can leave the state exactly
as is in each env directory and only source a different .env file for each
environment before running terraform. See [Switching Accounts](#switching-accounts) below, as in some cases you may also need to `az logout` and `az login`.

There are two terraform configurations in each env:

1. the `env/who/bootstrap/main.tf`, which creates the tfstate storage.
2. the `env/who/main.tf`, which uses the remote backend and runs the main module.

The cloudcity env has some extra resources that were manually created by the WHO in the WHO environment.

## Getting Env Files with Credentials

The env files live in the Cloud City's `C: VitalStrategies` 1Password vault.

The cloudcity environment file is `config/terraform/env/cloudcity/.env`. The WHO environment file is `config/terraform/env/who/.env`.

You should copy the contents of each file and put it in the same path as its name. The files will be gitignored and should never be checked in, because they contain secret credentials.

You will need your own Azure DevOps Personal Access Token (for each env) to substitute for Martin's expired one. If you don't already have one, you can make one at https://dev.azure.com.

## Main Provisioning - Terraform apply

Run the main terraform configuration like so:

    cd config/terraform/env/who
    az login
    source .env # the .env file you made above

Did the above command show the correct account? If so, proceed

    terraform init
    terraform apply

Check the changes and ensure you actually want to perform them.

### Fixing Expired GitHub PAT (Personal Access Token)

The Github PAT expires every year. 1 year is the max :(

It can be regenerated as the account benchmarks-service-acct, the login for which is in the Cloud City 1Password vault for Vital Strategies.

If you don't already have the newest .env, find the who/.env file in Cloud City 1Password.

- Add the new PAT to `TF_VAR_github_pat` in the .env file.
- Update the new expiry date in the `TF_VAR_github_pat_expiry` so that the pipeline can complete.
- Run `terraform apply`.
- Make sure you update 1Password with the new .env file that has the new token and expiry!

## Bootstrap Provisioning

**If the backend storage is already created, you don't need to touch bootstrap.**
Applying the bootstrap again should be a no-op.

### Bootstrapping a New Account

If you are deploying an environment from scratch, first bootstrap the tfstate
storage account with the following.

The .env file is in the Cloud City 1Password for Vital Strategies.

    cd config/terraform/env/who
    source .env
    cd bootstrap
    terraform init
    terraform apply

These must be run with local tfstate because they create the remote backend.

Update `config/terraform/env/who/main.tf` with the output from apply.

    # copy this output into the backend block.
    resource_group_name  = resource_group_name
    storage_account_name = storage_account_name
    container_name       = container_name

**IMPORTANT**: This updated `main.tf` must be checked into the repo in order for others to use the tfstate.

#### Import Bootstrap State (to change it)

If the backend storage already exists, you can import existing state into your
local terraform state, if needed.

You would need to do this in the circumstance that you are changing the tfstate that gets bootstraped in the `bootstrap` subfolder (not the cloudcity or who folders). Because we bootstrap with local tfstate (since there is no storage to store the tfstate in yet), that file lives on someone's computer. These commands would recreate that file from the existing infrastructure.

The following commands reference these variables, some of which are in:

    config/terraform/env/name/.env

- `ARM_SUBSCRIPTION_ID` - The subscription id also available from `az account show`
- `TF_VAR_tfstate_resource_group_name` - The existing resource group (`"IHRBENCHMARK-MAIN-WEU-RG01"`)
- `TFSTATE_STORAGE_ACCOUNT_NAME` - The name of the storage account (e.g. `"tfstateabc123abc"`).
  get this from `env/name/main.tf` in the backend section.

Once you have the correct ENV set, run the following commands to import

    cd config/terraform/env/who
    source .env
    cd bootstrap
    # this is not set in .env
    export TFSTATE_STORAGE_ACCOUNT_NAME=
    terraform init
    terraform import module.bootstrap.azurerm_storage_account.tfstate "/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${TF_VAR_tfstate_resource_group_name}/providers/Microsoft.Storage/storageAccounts/${TFSTATE_STORAGE_ACCOUNT_NAME}"
    terraform import module.bootstrap.azurerm_storage_container.tfstate "https://${TFSTATE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net/tfstate"

**IMPORTANT**: Don't destroy tfstate unless _everything_ in other terraform
run is already destroyed. Otherwise you'll have to manually cleanup the
resources that were created by terraform _without_ destroying the manually
created resources.

## Switching accounts

To switch to a different azure account, switch to the respective directory:

    cd config/terraform/env/cloudcity

Before you source the .env file, log out of the Azure cli and log back in with the correct account, if you have different accounts. (Such as a cloudcitydev.onmicrosoft.com account and a cloudcity.io account).

```
az logout
az login
```

Then source the .env file contained therein. Get the file from CloudCity's
1Password "Vital Strategies" vault if you don't have the .env file.

    source .env

Run the terraform plan. Make sure it doesn't try to destroy everything.

    terraform init
    terraform plan

### After Provisioning Azure DevOps Initially, Action is Required

#### To Link Github

The link between GitHub and Azure Pipelines must be created.
Use the Azure Pipelines GitHub Integration to create the connection.

After Azure DevOps is provisioned via Terraform, approval must be granted for
the Service Connection for Azure Devops to access the Azure Container Registry.

Go to the Azure Devops project portal https://dev.azure.com and view the pipeline.
After a build has been started, you should see a message on the page that says
that the pipeline cannot run until you click this button to approve the Service
Connection.

#### To Create the CI Agent Pools

In the project, go to `Settings>Agent Pools`.
Create a new agent pool based off the relevant resource group/service connection (uat for `uat-agents-no-docker` and prod for `prod-agents-no-docker`).
There should only be one scaleset in each resource group, use that to set up the pool.

NOTE: To delete an agent pool, you need to delete it from the `Organization Settings`. If you delete it from the `Project Settings`, you only remove that project from it, but the agent pool continues to exist.

## Destroy Everything

If you need to teardown the infrastructure, you can do so by running the
following commands. You probably don't want to do this on the WHO account.

You should first manually delete the DevOps agent pool in the ui. (You may need Martin's WIMS account to do this in the WHO account)

    az account set --subscription $ARM_SUBSCRIPTION_ID
    terraform destroy

## .env Setup Instructions for a new Azure subscription

So you want to deploy to a new Azure account.

First, recursively copy `config/terraform/env/cloudcity` to a new directory
in the env folder. Then copy `config/terraform/env/.env.sample` to
`config/terraform/env/newname/.env`

Make the necessary changes to the .env file to support your new env.

Change the backend after running the bootstrap step.

## Useful Commands

Tail application logs:

    az webapp log tail --resource-group IHRBENCHMARK-P-WEU-RG01 --name who-ihrbenchmark --slot staging --subscription "IHRBENCHMARK IHR Benchmarks Capacity application hosting"

# WHO-specific Background Things to know

There are certain resources that are long-lived and should never be destroyed.
These are created by a WHO admin and can be slow to replace because of a lack of
permissions to create these resources.

AzureRM:

- Resource Group: IHRBENCHMARK-MAIN-WEU-RG01
- Resource Group: IHRBENCHMARK-P-WEU-RG01
- Resource Group: IHRBENCHMARK-T-WEU-RG01

Azure DevOps:

- Azure DevOps Project: IHRBENCHMARK
- Almost all of the Service Connections

# Terraform resources for best practices and naming conventions

We have tried to observe best practices described in the following:

- https://www.terraform-best-practices.com/naming
- https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
- https://www.terraform-best-practices.com/code-styling
- https://github.com/antonbabenko/pre-commit-terraform
