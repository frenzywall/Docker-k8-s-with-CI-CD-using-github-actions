#!/bin/bash

echo "Script started at $(date)" >> /var/log/your_script.log


apt-get update


apt-get install -y curl apt-transport-https


curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

usermod -aG docker $(whoami)


curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

curl -LO "https://dl.k8s.io/release/v1.27.0/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl


dockerd-rootless-setuptool.sh install -f
docker context use rootless
minikube start --driver=docker --container-runtime=containerd

minikube status >> /var/log/your_script.log
kubectl version --client >> /var/log/your_script.log

echo "Script ended at $(date)" >> /var/log/your_script.log
