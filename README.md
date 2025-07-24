# 📦 Terraform AWS EKS Module (ECC)

This module provisions an **Amazon EKS Cluster** using **Terraform**, including managed node groups, with full customization support.  
It is designed to be reusable and version-controlled for DevOps and production-ready infrastructure.

---

## 🔐 Prerequisites

This EKS module **does not create a VPC or subnets**. You must create them separately before using this module.

You can use our VPC module here:  
👉 [ecc-tech/terraform-aws-vpc-ECC](https://github.com/ecc-tech/terraform-aws-vpc-ECC)

Ensure the following resources are available:
- VPC (`aws_vpc_id`)
- Public Subnets (`aws_subnet_public`)
- Private Subnets (`aws_private_subnet`)

---

## 📥 Input Variables

| Name                  | Type        | Description                                           | Required |
|-----------------------|-------------|-------------------------------------------------------|----------|
| `project`             | `string`    | Project name (used in tags and naming)               | ✅ Yes   |
| `cluster_name`        | `string`    | EKS Cluster name                                      | ✅ Yes   |
| `num_cluster`         | `number`    | Number of clusters to create (usually 1)             | ✅ Yes   |
| `desired_size_node`   | `number`    | Desired node count in node group                     | ✅ Yes   |
| `max_size_node`       | `number`    | Maximum node count                                   | ✅ Yes   |
| `min_size_node`       | `number`    | Minimum node count                                   | ✅ Yes   |
| `ami_type`            | `string`    | AMI type for worker nodes (e.g., `AL2_x86_64`)       | ✅ Yes   |
| `capacity_type`       | `string`    | Capacity type (e.g., `ON_DEMAND`, `SPOT`)            | ✅ Yes   |
| `disk_size_node`      | `number`    | Disk size for worker nodes in GiB                    | ✅ Yes   |
| `instance_types`      | `list`      | EC2 instance types for EKS nodes                     | ✅ Yes   |
| `owner_name_tag`      | `string`    | Owner tag for tracking                               | ✅ Yes   |
| `aws_vpc_id`          | `string`    | VPC ID (from VPC module)                             | ✅ Yes   |
| `aws_subnet_public`   | `list`      | Public subnet IDs (from VPC module)                  | ✅ Yes   |
| `aws_private_subnet`  | `list`      | Private subnet IDs (from VPC module)                 | ✅ Yes   |

---

<!--
## 📤 Outputs

| Output Name           | Description                                        |
|-----------------------|----------------------------------------------------|
| `eks_cluster_id`      | ID of the created EKS cluster                      |
| `eks_cluster_endpoint`| API server endpoint of the EKS cluster             |
| `eks_cluster_name`    | Name of the EKS cluster                            |
| `node_group_names`    | Names of the managed node groups created           |

> Outputs will help you integrate the EKS cluster into your CI/CD pipelines, `kubeconfig`, and monitoring tools.

---
-->
## 🚀 Usage Example

```hcl
module "vpc" {
  source = "git::https://github.com/ecc-tech/terraform-aws-vpc-ECC.git"
  
  project                  = "ecc-dev"
  vpc_cidr                 = "10.0.0.0/16"
  availability_zones       = ["us-east-1a", "us-east-1b"]
  subnet_cidr_bits         = 8
  availability_zones_count = 2
}

module "eks" {
  source               = "./modules/eks"

  project              = var.project
  cluster_name         = var.cluster_name
  num_cluster          = var.num_cluster
  desired_size_node    = var.desired_size_node
  max_size_node        = var.max_size_node
  min_size_node        = var.min_size_node
  ami_type             = var.ami_type
  capacity_type        = var.capacity_type
  disk_size_node       = var.disk_size_node
  instance_types       = var.instance_types
  owner_name_tag       = var.owner_name_tag

  aws_vpc_id           = module.vpc.aws_vpc_id
  aws_subnet_public    = module.vpc.aws_subnet_public
  aws_private_subnet   = module.vpc.aws_private_subnet
}
