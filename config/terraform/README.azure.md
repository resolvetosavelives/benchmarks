# Azure Readme

## Azure and Docker

Azure cloud resources are managed via Terraform.

The terraform configuration is in `config/terraform`. Secret values are put into a .env file in the terraform folder and sourced into the current shell session.

We run in Azure App Service for Containers.

The directory `config/docker` container the Dockerfiles. There are 2 Dockerfiles for multi-stage build:

1. a builder stage (install gems and packages, compile web assets)
2. a main Dockerfile that sources the builder stage and then configures the application

The builder stage is built on azure devops on a schedule. To compile the builder locally:

    docker build -t benchmarks_builder -f config/docker/builder/Dockerfile .

The main Dockerfile works with docker compose, which includes a postgres image as well.

To compile the main image locally:

    docker compose build

And to run it locally:

    docker compose up

To tinker with what docker has built:

- `yarn start` to start the resulting image but point it at a local database running on your local docker host (e.g. your laptop)
- `yarn up` to start the resulting image but instead of start the app process start an interactive shell so that you can poke around inside the docker container
- `yarn azstart` to start the resulting image and app server as Azure App Service would do

# Azure cloud resources used:

- Azure App Service for Containers
- Azure App Service Slots (Production, Staging)
- Azure App Service Plan
- Azure Database for PostgreSQL
- Azure PostgreSQL Databases
- Azure PostgreSQL Firewall Rules
- Azure Container Registry
- Azure Storage Container (terraform state)
- Azure Resource Groups (production, sandbox, terraform)

# Azure Devops resources used:

- Azure Devops Project
- Azure Devops Build Definition (aka "pipeline")
- Azure Devops Service Endpoint for GitHub
- Azure Devops Service Endpoint for Azure Container Registry

# Caveat

The Azure cloud resources we used (Database, Container Registry, Storage, etc) are accessible from any Azure Services. There was not time/scope/etc to get fully private networking working (see section: out of scope for this milestone.) This is a built-in setting that Azure provides, in the web portal its called "Allow access to Azure services". This also has the effect that other Azure customers could possibly reach our cloud resources from within Azure's own networks/data centers.

## CHANGES FOR THIS APP

This app now fully makes use of Rails Credentials. This is because I found managing many environment variables unwiedly in Azure (without additional tooling, which was out of scope for this milestone.) There is a file `config/credentials.yml.enc` that is an symmetrically encrypted YAML document. This file contains the env vars listed in the README, which currently/previously resided in Heroku. This file may be decrypted/edited by developers by having the `config/master.key` file present on their system and then using the built-in Rails rake tasks. This app in Production mode uses the RAILS_MASTER_KEY env var at the command line to decrypt and access the credentials file.

Along with the Azure-related new code and modifications to the app, there are some indirect code changes: some are to work better/easier with Azure, some are to avoid problems with Azure or tooling, and some are white space that were applied as files were changed and committed.

### Major Changes:

- Node.js version `15.14.0` => `16.4.2`
- Remove `RAILS_SERVE_STATIC_FILES` because Production should to equal true and fewer env vars to manage.
- Remove `NO_SSL` becuse Production in Azure needs to run HTTP (without SSL) on port 80. And fewer env vars.
- Remove `RAILS_LOG_TO_STDOUT` because Production in Azure should do this and fewer env vars. And fewer env vars.

### Azure-specific points:

- Add gem `tzinfo`.
- Web host name constant `BENCHMARKS_HOST` => `APPLICATION_HOST`.
- Remove constant `SENTRY_AUTH_TOKEN` which enables uploading of source maps to Sentry at release time but was problematic with Azure (could be re-added later).
- Azure App Service app setting constant `DOCKER_ENABLE_CI` is omitted from Azure/MS documentation.
- Use full paths for starting the app via puma (errors occur otherwise.)

## KNOWN ISSUES WITH THIS APP AND AZURE:

- At runtime within the Azure App Service environment, paths behave strangely/in an unknown fashion and so commands will fail unless called without absolute paths. Consequently, we are not using Procfile to run in Azure, we are using a command in the Dockerfile which uses full paths.
  - There is extra troubleshooting code in the third Dockerfile that dumps out things like $PWD and ls -l of various locations which is still in there and proves helpful when troubleshooting in Azure.
- Assets were not working in the East US 2 Availability Region, but started working in the West Europe Region.
  - Support request was filed with Azure. Will fix this as part of current milestone.
  - As an attempted workaround, the Dockerfile deletes the compressed (_.gz, _.br) versions of web assets (CSS, etc) but it may be removed since it appears to fail to have the desired affect. This problem will be worked on after this PR (and as part of this milestone).
- Terraform state is currently stored in an Azure Storage Container which gives us shared terraform state which is better and encrypted in transit and at rest. However, there are still some state files in the code; they may be vestigial and may be removable.
- Currently, the CI test run-related steps of the pipeline are commented out. This is because recent work was focused on build/release Azure stuff and not-so-much on app functionality, so the deploy process happens much faster without this. I would prefer to comment it back in later upon the merge to a mainline branch.
- I am currently using a Personal Access Token for my own GitHub account in order to authenticate Azure Pipline with GitHub: it expires fewer than 90 days / should be changed to an admin or bot account.
- Currently there are 2 databases we use, one for CI Pipeline and another for Staging. They both use the same admin credentials. I tried to split them out to have separate creds for each, but it appears that Azure does not support this, or that we may have to switch from admin creds to Azure System Identities.
- Currently, the Azure deployment with which I have been working is my own Azure Account and Subscription. I think it would be better to get this reviewed as-is and then make that change, which may result in (minor) changes.
- WHO Azure-related documentation specifies 4 Resource Groups: Production, Test, Development, U (User acceptance?). We have 2 Resource Groups for cloud resources (production and sandbox) and another for terraform state storage. Each non-terraform Resource Group contains a full set of infrastructure (database, container registry, etc) and applications (one staging instance with CI, and one production instance using slots to easily promote staging to Production.) If we ought to build more or re-arrange the layout we can do that later.

## KNOWN ISSUES, OTHER:

- Should have a README file that provides instructions to developers how to use terraform to provision/amend Azure cloud resources including a blurb about how to work with secrets/passwords with terraform.
- The Semaphore CI build fails with this branch and will need to be updated for JS version.
- Would be nice to make use of terraform modules for common chunks of configuration.
- Would be nice to clean up full paths and other troubleshooting code still present after the other stories that are part of the current milestone are resolved.

## OUT OF SCOPE FOR THIS MILESTONE

There was a significant amount of effort spent on attempting to make use of certain Azure cloud resources that would provide an even higher level of network security via isolation. The code from that work resides in branch `azure-vnet` and may be useful as a reference.

The Azure cloud resources involved in this are listed below. This list is not exhaustive.

- Azure Virtual Network (VNet)
- Subnets
- Azure VPN Gateway
- Private Link
- Private Link for Postgresql Database
- Private Link for Azure Container Registry
- Private Service Endpoints
- Vnet Peering for App Service
- Network Security Groups

This approach would provide higher security by effectively making our cloud resources (database, container reg, etc) local to our private network, giving us network-level control over these services and a high level of control and security customizability.

The "bridge too far" of this was that Azure Devops Pipeline could not access the Database nor the Container Registry. After much time spent investigating solo and with Azure support personnel, the issue was: by default Azure CI Pipelines use agents to run the pipeline jobs that are Microsoft-hosted. This means that the CI job agents are hosted by Microsoft within Azure Devops which means they are not local to an Azure region and thus outside of our private VNet and cannot access fully private resources which are "tethered" to our private VNet. Thus, in order for job agents to access clour resources secured with Private Link or Private Service Endpoints, we would need to implement and deploy our own CI job agents within our VNet/subnet that phone home to Azure Devops in a separate network/data center.

We were succeedful in getting our app running in App Service to talk to the Azure Database for Postgres secured with Private Link thanks to VNet peering between App Service to a dedicated subnet on our private VNet, making our app and App Service effectively local to our private network VNET. So this approach would have worked for App Service to talk to our Container Registry secured with Private Link. Azure Devops was the outlier.

## MISC

- The terraform code contains Azure identifiers such as subscription_id and tenant_id. These are anchored under my Azure Account and anyone using them would have to authenticate as a valid user of my account including 2FA. They are generally not considered sensitive values.
- Did not make full use of Markdown for this document because it mangled certain bits such as constants without back ticks.
