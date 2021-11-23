#!/bin/bash

cat <<EOF
This script will install the pre-requisite tooling for Tanzu Application Platform
on Ubuntu-like systems.

You may be prompted for your password for 'sudo' commands and you will
also need to supply a 'UAA API refresh token' to access files from the Tanzu
Network site. To obtain such a token:

* Go to https://network.tanzu.vmware.com
* Sign in
* Select the drop-down menu that appears when you click on your name
  at the top right-hand corner of the page
* Click on 'Edit Profile'
* At the bottom of the page click on 'Request New Refresh Token'
* Make a copy of the token

EOF
read -p "Hit return to continue: " GO

function log() {
  local line

  echo ""
  for line in "$@"
  do
    echo ">>> $line"
  done
  echo ""
}

function usingWsl() {
  uname -r | grep -qi 'microsoft'
}

if [[ "$(uname -s)/$(uname -m)" != "Linux/x86_64" ]]
then
  log "Sorry, this script only handles Linux x86_64 systems"
  exit 1
fi

log "Installing basic tools"

sudo apt-get update -y
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  jq

if usingWsl
then
  log "It looks like you are running under WSL" \
    "You must install Docker Desktop if you have not done so already" \
    "This script will install the docker CLI only"

  sudo apt-get install -y docker

else
  log "Removing any existing docker installation"

  sudo apt-get remove -y docker docker-engine docker.io containerd runc

  log "Installing new version of docker"

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

log "Adding $USER to docker group (logout/in to take effect)"
sudo usermod -a -G docker $USER

DOWNLOADS=/tmp/downloads
mkdir -p $DOWNLOADS

log "Installing kubectl"

curl -Lo $DOWNLOADS/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 $DOWNLOADS/kubectl /usr/local/bin/kubectl


log "Done"
