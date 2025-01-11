# Terraform Configuration for AWS S3 Static Website Hosting

This folder contains the Terraform configuration files for deploying a static website on AWS S3. The infrastructure setup includes features such as static website hosting, cross-region replication, bucket encryption, versioning, and lifecycle policies.

---

## Features

1. **Static Website Hosting**:
   - Host a static website using Amazon S3.
   - Configured with an index and error document.

2. **Cross-Region Replication**:
   - Replicate objects from the primary S3 bucket to a secondary bucket in a different region for disaster recovery.

3. **Security**:
   - Server-side encryption (SSE) enabled for data protection.
   - Public access is strictly managed using bucket policies and public access block settings.

4. **Versioning**:
   - Retain multiple versions of objects in the bucket to recover from accidental deletions or overwrites.

5. **Cost Optimization**:
   - Lifecycle policies automatically transition objects to cheaper storage classes as they age.

---

## Prerequisites

- An **AWS account** with sufficient permissions.
- **Terraform** installed on your local machine ([Download Terraform](https://www.terraform.io/downloads)).
- **AWS CLI** installed and configured ([AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)).

---

## Configuration Overview

### Files
- `main.tf`: Defines the AWS resources for the S3 static website setup.
- `variables.tf` (if applicable): Defines configurable input variables for the Terraform configuration.
- `outputs.tf` (if applicable): Specifies the output values to retrieve resource details after deployment.
- `providers.tf` (optional): Specifies the AWS provider and region configuration.

---

## Usage

### Step 1: Clone the Repository
Clone this repository to your local machine:
git clone https://github.com/imkdesai/AWS-S3-Static-Website.git
cd AWS-S3-Static-Website/terraform


