#
# NB: this is not yet working. this would be the first use of the azuredevops provider in this project.
#

terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}

provider "azuredevops" {
  # Configuration options
}

resource "azuredevops_project" "project" {
  project_name       = "WhoIhrBenchmarks001"
  description        = "WHO IHR Benchmarks Project"
}
