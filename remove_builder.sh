#!/bin/bash

if [[ -z $1 ]]
then
    echo "No name provided. Please enter the required argument:"
    read -r builder_name
else
    builder_name=$1
fi

workdir=$(dirname "$(readlink -f "$0")")

cd "$workdir/terraform" || exit 1

# Remove a builder instance
echo "Removing buildx instance..."
docker buildx rm -f "${builder_name}"

# Remove local TLS certificates
echo "Removing TLS certificates.."
rm -rf "$workdir/ansible/.certs/"

# Destroy remote instance
echo "Destroying ec2 instance..."
terraform destroy -auto-approve