variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}


variable "project" {
  description = "The project name for tagging resources"
  type        = string
}



variable "num_cluster" {
    description = "Number of EKS clusters to create"
    type        = number
}

variable "desired_size_node" {
  description = "Desired number of nodes in the EKS cluster"
  type        = number
  
}

variable "max_size_node" {
  description = "Maximum number of nodes in the EKS cluster"
  type        = number
  
}

variable "min_size_node" {
  description = "Minimum number of nodes in the EKS cluster"
  type        = number  
  
}

variable "ami_type" {
  description = "AMI type for the EKS nodes"
  type        = string
#   default     = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM

}

variable "capacity_type" {
  description = "Capacity type for the EKS nodes"
  type        = string
  #default     = "ON_DEMAND" # ON_DEMAND, SPOT
  
}

variable "disk_size_node" {
  description = "Disk size for the EKS nodes in GB"
  type        = number
  #default     = 15
  
}
variable "instance_types" {
  description = "Instance types for the EKS nodes"
  type        = list(string)
  #default     = ["t2.medium"]
  
}

# variable "project" {
#   description = "Project name for tagging resources"
#   type        = string  
#   # deafult     = "actin-lower-environments"
  
# }

variable "owner_name_tag" {
  description = "Owner name for tagging resources"
  type        = string
  # default     = "actin_terraform"
  
}
variable "aws_subnet_public" {
  description = "List of public subnet IDs"
  type        = list(string)
  
}

variable "aws_private_subnet" {
  description = "List of private subnet IDs"
  type        = list(string)
  
}

variable "aws_vpc_id" {
  description = "VPC ID"
  type        = string
  
}
# variable "aws_internet_gateway_id" {
#   description = "Internet Gateway ID"
#   type        = string
#   default     = null
  
# }