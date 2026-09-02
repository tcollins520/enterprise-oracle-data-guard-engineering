# Phase 2 - Terraform Bootstrap

## Overview

This phase establishes the Terraform remote backend used throughout the project.

Rather than storing Terraform state locally, remote state is stored securely in Amazon S3 with versioning enabled and protected using DynamoDB state locking.

## Resources Created

- Amazon S3 Bucket
- S3 Versioning
- Server-Side Encryption (AES256)
- Public Access Block
- DynamoDB Lock Table

## Benefits

- Shared remote state
- State locking
- Version history
- Encrypted state
- Production-ready Terraform workflow

## Usage

```bash
terraform init

terraform fmt

terraform validate

terraform plan -var-file=terraform.tfvars

terraform apply -var-file=terraform.tfvars
```