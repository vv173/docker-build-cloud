#!/bin/bash

if [[ -z $1 ]]
then
    echo "No name provided. Please enter the required argument:"
    read -r builder_name
else
    builder_name=$1
fi

# Check if Terraform, Ansible, and AWS CLI are installed
utils=("aws" "terraform" "ansible")
for i in "${utils[@]}"
do
    if ! command -v "$i" &> /dev/null
    then
        echo "$i is not installed"
        exit 1
    fi
done

# Check if AWS CLI is authenticated
aws_auth=$(aws sts get-caller-identity --output json 2>&1)

if [[ $? -eq 0 ]]
then
    echo "AWS CLI is authenticated"
else
    echo "Failed to authenticate with AWS CLI."
    echo "Error details: $aws_auth"
    exit 1
fi

workdir=$(dirname "$(readlink -f "$0")")

cd "$workdir/terraform" || exit 1

# Initialize and apply Terraform
echo "Initializing Terraform..."
terraform init

echo "Applying Terraform..."
terraform apply -auto-approve

instance_id=$(terraform output -raw ec2_id)
instance_ip=$(terraform output -raw eip)
instance_hostname=$(terraform output -raw dns_name)

# Check for the availability of the EC2 instance
echo "Waiting until instance is up and running..."
aws ec2 wait instance-status-ok --instance-ids "$instance_id"

# Run Ansible playbook
echo "Running Ansible playbook..."
export ANSIBLE_CONFIG="$workdir/ansible/ansible.cfg"
ansible-playbook "$workdir/ansible/main.yml" -i inventory.yml

# Create a builder instance
echo "Adding remote instance to the local docker client..."
docker buildx create \
    --name "${builder_name}" \
    --driver remote \
    --driver-opt cacert="${workdir}"/.certs/client/ca.pem,cert="${workdir}"/.certs/client/cert.pem,key="${workdir}"/.certs/client/key.pem,servername="${instance_hostname}" tcp://"${instance_hostname}":1537 \
    --bootstrap \
    --use \
    --platform=linux/amd64,linux/arm64,linux/s390x,linux/arm/v7,linux/arm/v6