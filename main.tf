
# EKS Cluster 1
resource "aws_eks_cluster" "cluster1" {
  count = var.num_cluster
  name     = "${var.cluster_name}-${count.index + 1}-${var.project}"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.29"
  enabled_cluster_log_types = ["audit", "api", "authenticator", "scheduler"]
  vpc_config {
    subnet_ids = concat(var.aws_subnet_public, var.aws_private_subnet)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]

  
  }

  tags = {
    "Name"          = "${var.project}-ng-${count.index + 1}",
    "ClusterIndex"  = count.index + 1,
    "kubernetes.io/cluster/${var.project}-cluster" = "owned"
    "environment" = local.workspace_name
    "Owner" = var.owner_name_tag

  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}


# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name = "${var.project}-Cluster-Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}


# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.aws_vpc_id

  tags = {
    Name = "${var.project}-cluster-sg"
  }
}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress"
}

# EKS Node Group 1
# Local Variables, defined  workspace name for state management
locals {
  workspace_name = terraform.workspace
}

resource "aws_eks_node_group" "cluster1_ng" {
  count = var.num_cluster
  cluster_name    = "${var.cluster_name}-${count.index + 1}-${var.project}"
  node_group_name = "${var.cluster_name}-ng-${count.index + 1}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.aws_private_subnet
  

  scaling_config {
    desired_size = var.desired_size_node
    max_size     = var.max_size_node
    min_size     = var.min_size_node
  }

  ami_type       =  var.ami_type # "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
  capacity_type  = var.capacity_type  # ON_DEMAND, SPOT
  disk_size      = var.disk_size_node
  instance_types = var.instance_types

  tags = {
    "Name"          = "${var.project}-ng-${count.index + 1}"
    "ClusterIndex"  = count.index + 1
    "kubernetes.io/cluster/${var.project}-cluster" = "owned"
    "environment" = local.workspace_name
    "Owner" = var.owner_name_tag

  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.cluster1
  ]
}


# # EKS Node Group 2

# resource "aws_eks_node_group" "cluster2_ng2" {
#   cluster_name    = "${var.cluster2_name}-${var.project}"
#   node_group_name = "${var.cluster2_name}-ng2"
#   node_role_arn   = aws_iam_role.node.arn
#   subnet_ids      = [
#     aws_subnet.private[0].id,
#   ]

#   scaling_config {
#     desired_size = 4
#     max_size     = 10
#     min_size     = 4
#   }

#   ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
#   capacity_type  = "ON_DEMAND"  # ON_DEMAND, SPOT
#   disk_size      = 15
#   instance_types = ["t2.medium"]

#   tags = merge(
#     var.tags,
#     {
#       "ClusterIndex" = 2
#     }
#   )

#   depends_on = [
#     aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
#     aws_eks_cluster.cluster1
#   ]
# }




# EKS Node IAM Role
resource "aws_iam_role" "node" {
  name = "${var.project}-Worker-Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}


# EKS Node Security Group
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project}-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.aws_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                           = "${var.project}-node-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "owned"
  }
}

resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}