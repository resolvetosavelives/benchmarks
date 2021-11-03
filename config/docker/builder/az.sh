##
# This file contains snippets to create/delete Tasks for our Azure Container Registry (ACR)
# It is NOT TO BE RUN DIRECTLY. It is named as a ".sh" file to aid with syntqax highlighting
#   and auto-complete only.
##

# az acr login -n whoihrbenchmarksregistry

##
# BUILDER image
az acr task create \
  -r whoihrbenchmarksregistry \
  -n taskToRebuildTheBuilderImage \
  -c https://github.com/resolvetosavelives/benchmarks.git#automate-docker-image-builds-with-acr-from-the-pipeline--179500509 \
  -f config/docker/builder/Dockerfile \
  --schedule "0 1 * * *" \
  --commit-trigger-enabled false \
  --base-image-trigger-enabled false \
  -t benchmarks-builder:latest

#az acr task delete \
#  -r whoihrbenchmarksregistry \
#  -n taskToRebuildTheBuilderImage

##
# BASE image
az acr task create \
  -r whoihrbenchmarksregistry \
  -n taskToRebuildTheBaseImage \
  -c https://github.com/resolvetosavelives/benchmarks.git#automate-docker-image-builds-with-acr-from-the-pipeline--179500509 \
  -f config/docker/base/Dockerfile \
  --schedule "0 2 * * *" \
  --commit-trigger-enabled false \
  --base-image-trigger-enabled false \
  -t benchmarks-base:latest

#az acr task delete \
#  -r whoihrbenchmarksregistry \
#  -n taskToRebuildTheBaseImage
