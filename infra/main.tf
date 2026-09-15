# Get the latest Amazon Linux 2023 AMI automatically (best practice - never hardcode AMI IDs)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Use the default VPC for simplicity in this learning project
data "aws_vpc" "default" {
  default = true
}

# Security group - NO inbound SSH (port 22). We use SSM instead.
resource "aws_security_group" "app_sg" {
  name        = "gha-node-ci-pipeline-sg"
  description = "Allow outbound only; app reachable on 80 for demo"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from anywhere (demo only)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM role the EC2 INSTANCE itself uses (separate from GitHub's role)
resource "aws_iam_role" "ec2_ssm_role" {
  name = "gha-node-ci-pipeline-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# AWS-managed policy that lets SSM Agent on the instance register/communicate
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "gha-node-ci-pipeline-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_iam_role_policy" "ec2_s3_read" {
  name = "ec2-s3-release-read"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::tf-state-gha-node-ci-pipeline-shambhavimaya-code/releases/*"
      }
    ]
  })
}


# The actual EC2 instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name
  user_data              = file("${path.module}/user_data.sh")

  tags = {
    Name = "gha-node-ci-pipeline-app"
  }
}
