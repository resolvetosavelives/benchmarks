# This terraform config runs in the pipeline
# It doesn't specify a backend because it is specified in the pipeline task 
terraform {}

module "main" {
  source = "../../main"
  # temporarily hard code this, it should be fed in by the bootstrap devops module
  organization_prefix      = "ccd" # var.organization_prefix 
  devops_project_name      = var.devops_project_name
  prod_resource_group_name = var.prod_resource_group_name
  test_resource_group_name = var.test_resource_group_name
}
