![image](https://github.com/vikash-kumar01/3_tier_webapp/assets/35370115/f802a121-bba9-4e1b-95f4-fee541c640fa)

![image](https://github.com/vikash-kumar01/3_tier_webapp/assets/35370115/f213e108-6c7d-483e-89f3-326d2ae80ef9)


# Steps to Run this Terraform Module

This repository contains a Terraform module for Depployment of 3Tier Infra.

## Prerequisites

Before you begin, ensure you have the following prerequisites:

- Terraform installed on your machine.
- AWS credentials configured.

## Instructions

### Step 1: Initialize Terraform

Open a terminal and navigate to the root of the repository. Run the following command to initialize the Terraform configuration:

terraform init


### Step 2: Initialize Plan

terraform plan --var-file=./config/terraform.tfvars.json


### Step 2: Initialize Apply

terraform apply --var-file=./config/terraform.tfvars.json --auto-approve
