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

  tags = {
    Name = "vehicle-sales-subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.2.0/24"

  availability_zone = "sa-east-1b"

  tags = {
    Name = "vehicle-sales-subnet-b"
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

  role       = aws_iam_role.eks_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "cluster" {

  name = var.cluster_name

  role_arn = aws_iam_role.eks_role.arn

  vpc_config {

    subnet_ids = [
      aws_subnet.subnet_a.id,
      aws_subnet.subnet_b.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}