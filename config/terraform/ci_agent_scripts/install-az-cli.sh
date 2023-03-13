#!/usr/bin/env bash

set -eux

sudo apt remove azure-cli -y && sudo apt autoremove -y

sudo apt-get clean
sudo apt-get upgrade -y
sudo apt-get update -y

# Install packages needed to get and install the azure cli
sudo apt-get install -y \
  curl \
  lsb-release \
  software-properties-common \
  ca-certificates \
  apt-transport-https \
  gnupg

# Get and trust the microsoft package gpg key
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Add the microsoft repository as an apt source
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list


sudo apt-get install -y azure-cli