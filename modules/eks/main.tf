resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vehicle-sales-vpc"
  }
}

resource "aws_subnet" "subnet_a" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "sa-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "vehicle-sales-subnet-a"

    "kubernetes.io/cluster/${var.cluster_name}" = "shared"

    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "subnet_b" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.2.0/24"

  availability_zone = "sa-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "vehicle-sales-subnet-b"

    "kubernetes.io/cluster/${var.cluster_name}" = "shared"

    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_iam_role" "eks_role" {

  name = "vehicle-sales-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"

        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role = aws_iam_role.eks_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_security_group" "eks" {

  name = "vehicle-sales-eks-sg"

  vpc_id = aws_vpc.main.id

  ingress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    self = true
  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_eks_cluster" "cluster" {

  name = var.cluster_name

  role_arn = aws_iam_role.eks_role.arn

  vpc_config {

    subnet_ids = [
      aws_subnet.subnet_a.id,
      aws_subnet.subnet_b.id
    ]

    security_group_ids = [
      aws_security_group.eks.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_iam_role" "node_group_role" {

  name = "vehicle-sales-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {

  role = aws_iam_role.node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {

  role = aws_iam_role.node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {

  role = aws_iam_role.node_group_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "main" {

  cluster_name = aws_eks_cluster.cluster.name

  node_group_name = "vehicle-sales-node-group"

  node_role_arn = aws_iam_role.node_group_role.arn

  subnet_ids = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]

  scaling_config {

    desired_size = 2

    min_size = 1

    max_size = 3
  }

  instance_types = [
    "t3.micro"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]
}

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vehicle-sales-igw"
  }
}

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "subnet_a" {

  subnet_id = aws_subnet.subnet_a.id

  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_b" {

  subnet_id = aws_subnet.subnet_b.id

  route_table_id = aws_route_table.public.id
}