# How to Use This: Provisioning and Managing This Project's Azure Deployments with Terraform

```
 azuredevops_project.project "IHRBENCHMARK"
terraform import azuredevops_serviceendpoint_github.serviceendpoint_for_who_github 679f7d50-14c7-4b17-aea0-cc0e0452141b/0d3d26b6-fa89-4314-b91f-dc18e069a176
```

# Things to Know About Terraform on this Project

## Lets try to follow the conventions defined here:

- https://www.terraform-best-practices.com/naming
- https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

### Naming Convention for Azure Resources

![Image showing Azure's suggested naming convention for cloud resources](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/_images/ready/resource-naming.png)
This image is from https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

We'll attempt to stick to Azure's suggestions, with a simplifications to omit

| Naming component            | Description                                                                                                                                                                                                                                             |
| :-------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Resource type               | An abbreviation that represents the type of Azure resource or asset. This component is often used as a prefix or suffix in the name. For more information, see Recommended abbreviations for Azure resource types. Examples: rg, vm                     |
| ~~Business unit~~           | Top-level division of your company that owns the subscription or workload the resource belongs to. In smaller organizations, this component might represent a single corporate top-level organizational element. Examples: fin, mktg, product, it, corp |
| Application or service name | Name of the application, workload, or service that the resource is a part of. Examples: navigator, emissions, sharepoint, hadoop                                                                                                                        |
| ~~Subscription type~~       | Summary description of the purpose of the subscription that contains the resource. Often broken down by deployment environment type or specific workloads. Examples: prod, shared, client                                                               |
| ~~Deployment environment~~  | The stage of the development lifecycle for the workload that the resource supports. Examples: prod, dev, qa, stage, test                                                                                                                                |
| ~~Region~~                  | The Azure region where the resource is deployed. Examples: westus, eastus2, westeu, usva, ustx                                                                                                                                                          |

That leaves "Resource type" and "Application or service name". So we'll go with this for now. We are still figuring this out.

### Code Style for Terraform

- Use \_ (underscore) instead of - (dash/hyphen) in all: resource names, data source names, variable names, outputs.
  - Beware that actual cloud resources have many hidden restrictions in their naming conventions. Some cannot contain dashes, some must be camel cased. These conventions refer to Terraform names themselves.
- Only use lowercase letters and numbers.
-

#### Resource and data source arguments

- Do not repeat resource type in resource name (not partially, nor completely):
  - Good: resource "aws_route_table" "public" {}
  - Bad: resource "aws_route_table" "public_route_table" {}
  - Bad: resource "aws_route_table" "public_aws_route_table" {}
- Resource name should be named this if there is no more descriptive and general name available, or if resource module creates single resource of this type (eg, there is single resource of type aws_nat_gateway and multiple resources of typeaws_route_table, so aws_nat_gateway should be named this and aws_route_table should have more descriptive names - like private, public, database).
- Always use singular nouns for names.
- Use - inside arguments values and in places where value will be exposed to a human (eg, inside DNS name of RDS instance).
- Include count argument inside resource blocks as the first argument at the top and separate by newline after it. See example.
- Include tags argument, if supported by resource as the last real argument, following by depends_on and lifecycle, if necessary. All of these should be separated by single empty line. See example.
- When using condition in count argument use boolean value, if it makes sense, otherwise use length or other interpolation. See example.
- To make inverted conditions don't introduce another variable unless really necessary, use 1 - boolean value instead. For example, count = "${1 - var.create_public_subnets}"

## Someday

- https://www.terraform-best-practices.com/code-styling
- https://github.com/antonbabenko/pre-commit-terraform
