# Remote-Buildkit

## Overview
Remote-Buildkit is a bash script that automates the setup of a remote build environment using BuildKit on AWS EC2 instances. It leverages Terraform for provisioning and Ansible for configuration, streamlining the creation and integration of a remote BuildKit instance with your local machine.

## Features
- **Automated Provisioning**: Utilizes Terraform to automatically provision AWS EC2 instances.
- **Configuration Management**: Ansible scripts configure the instances by installing Docker and the BuildKit daemon.
- **Local Integration**: Bash script connects the remote BuildKit instance with your local development machine for easy access and control.

## Prerequisites
Before you begin, ensure you have the following installed on your local machine:
- Terraform
- Ansible
- AWS CLI
- Docker

Additionally, you will need:
- An AWS account
- Configured AWS CLI with appropriate permissions to create and manage EC2 instances, security groups, etc.
- Set the following environment variables for AWS access:
  ```bash
  export AWS_ACCESS_KEY_ID="your_access_key_id"
  export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
  ```

<!-- ## Installation
1. **Clone the Repository:**
   ```bash
   git clone https://github.com/yourusername/remote-buildkit.git
   cd remote-buildkit
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Deploy the Infrastructure:**
   ```bash
   terraform apply
   ```

4. **Run Ansible Playbook:**
   ```bash
   ansible-playbook setup.yml
   ``` -->

## Usage
After deployment, the remote BuildKit instance will be connected to your local machine. To verify the connection and see your BuildKit instance listed among available builders, use:
```bash
docker buildx ls
```

## Customization
You can customize the Ansible playbook and Terraform scripts to tweak the configuration of the AWS resources according to your needs.

## Contributing
Contributions are welcome! Please fork the repository and submit pull requests, or open issues to suggest improvements or report bugs.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
