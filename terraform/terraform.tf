terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.43.0"
    }

    ansible = {
      version = "~> 1.2.0"
      source  = "ansible/ansible"
    }
  }

  required_version = ">= 1.7.0"
}
