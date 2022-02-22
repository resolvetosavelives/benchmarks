# How to Use This: Provisioning and Managing This Project's Azure Deployments with Terraform

## Setup

Install the Azure command-line interface tool known as `az`. On MacOS:

    brew install az

Install terraform. On MacOS:

    brew install terraform

Login to the `az` CLI - You may be prompted to choose which login account and prompted to 2FA if enabled

    az login
    az account list
    az account set --subscription $ARM_SUBSCRIPTION_ID # this will be set by source .env later
    az account show

## Directory layout

You will find different folders in `config/terraform/env` for the different
places that this app can be deployed. This uses the "main module pattern" to
avoid duplication and manual terraform state file copying.

Without this directory structure, it is difficult to move between terraform
configurations for each azure account without copying and backing up the local
`.terraform` directory, changing environment variables, and switching the
backend manually in the main.tf. Since each env directory contains its own
state, while sharing the actual configuration, we can leave the state exactly
as is and only source a different .env file for each environment.

There are two terraform configurations in each env:

1. the `env/who/bootstrap`, which creates the tfstate storage.
2. the `env/who/main.tf`, which sets the remote backend, then runs the main module.

## Bootstrap Provisioning

**ONLY DO THIS IN A NEW SUBSCRIPTION**

If the backend storage is already created, you don't need to touch bootstrap.j

### Bootstrapping a New Account

If you are deploying an environment from scratch, first bootstrap the tfstate
storage account with the following.

    cd config/terraform/env/who
    source .env
    cd bootstrap
    terraform init
    terraform workspace select production
    terraform apply

These must be run with local tfstate because they create the remote account.

Update `config/terraform/env/who/main.tf` with the output from apply.

    # copy this output into the backend block.
    resource_group_name  = resource_group_name
    storage_account_name = storage_account_name
    container_name       = container_name

### Import Bootstrap State

You can import existing state into your local terraform state if needed.

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
    terraform workspace select production
    terraform import module.bootstrap.azurerm_storage_account.tfstate "/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${TF_VAR_tfstate_resource_group_name}/providers/Microsoft.Storage/storageAccounts/${TFSTATE_STORAGE_ACCOUNT_NAME}"
    terraform import module.bootstrap.azurerm_storage_container.tfstate "https://${TFSTATE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net/tfstate"

**IMPORTANT**: Don't destroy tfstate unless _everything_ in other terraform
run is already destroyed. Otherwise you'll have to manually cleanup the
resources that were created by terraform without destroying the manually
created resources.

## Main Provisioning

Run the main configuration like so:

    cd config/terraform/env/who
    source .env

Did the above command show the correct account? If so, proceed

    terraform init
    terraform workspace select production
    terraform apply

Check over the changes and ensure you actually want to perform them.

## Switching accounts

To switch to a different azure account, switch to the respective directory:

    cd config/terraform/env/cloudcity

Then source the .env file contained therein. Get the file from CloudCity's
1Password "Vital Strategies" vault if you don't have the .env file.

    source .env

In this example, we switch from WHO Azure to Cloud City Azure for testing:
The .env.cloudcity file is in the Cloud City Benchmark 1Password Vault.

    source .env.cloudcity
    az account set --subscription $ARM_SUBSCRIPTION_ID

Run the terraform plan. Make sure it doesn't try to destroy everything.

    terraform init
    terraform workspace select production
    terraform plan

### After Provisioning Azure DevOps, Action is Required

The link between GitHub and Azure Pipelines must be created.
Use the Azure Pipelines GitHub Integration to create the connection.

After Azure DevOps is provisioned via Terraform, approval must be granted for
the Service Connection for Azure Devops to access the Azure Container Registry.

Go to the Azure Devops project portal https://dev.azure.com and view the pipeline.
After a build has been started, you should see a message on the page that says
that the pipeline cannot run until you click this button to approve the Service
Connection.

## Destroy

If you need to teardown the infrastructure, you can do so by running the following commands:

    az account set --subscription $ARM_SUBSCRIPTION_ID
    terraform workspace select sandbox
    terraform destroy

## .env Setup Instructions for a new Azure subscription

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
