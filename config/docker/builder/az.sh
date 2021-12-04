##
# This file contains snippets to create/delete Tasks for our Azure Container Registry (ACR)
# It is NOT TO BE RUN DIRECTLY. It is named as a ".sh" file to aid with syntax highlighting
#   and auto-complete only.
##

# az acr login -n whoihrbenchmarksregistry

##
# BUILDER image
az acr task create \
  -r whoihrbenchmarksregistry \
  -n taskToRebuildTheBuilderImage \
  -c https://github.com/resolvetosavelives/benchmarks.git#main-azure \
  -f config/docker/builder/Dockerfile \
  --schedule "0 1 * * *" \
  --commit-trigger-enabled false \
  --base-image-trigger-enabled false \
  -t benchmarks_builder:latest

#az acr task delete \
#  -r whoihrbenchmarksregistry \
#  -n taskToRebuildTheBuilderImage

az acr task run \
  -r whoihrbenchmarksregistry \
  -n taskToRebuildTheBuilderImage

##
# BASE image
az acr task create \
  -r whoihrbenchmarksregistry \
  -n taskToRebuildTheBaseImage \
  -c https://github.com/resolvetosavelives/benchmarks.git#main-azure \
  -f config/docker/base/Dockerfile \
  --schedule "0 2 * * *" \
  --commit-trigger-enabled false \
  --base-image-trigger-enabled false \
  -t benchmarks_base:latest

#az acr task delete \
#  -r whoihrbenchmarksregistry \
#  -n taskToRebuildTheBaseImage

az acr task run \
  -r whoihrbenchmarksregistry \
  -n taskToRebuildTheBaseImage
