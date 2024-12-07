provider "aws" {
  region = "us-east-1"
}


# Creating the S3 bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket = "anigaikwadbucket16" 
  
  tags = {
    Name        = "S3 Bucket"
    Environment = "Development"
  }
}


# Create placeholder directories
resource "aws_s3_object" "dir1_placeholder" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "dir1/" 
}

resource "aws_s3_object" "dir2_placeholder" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "dir2/" 
}

# Create files in dir2
resource "aws_s3_object" "file1_in_dir2" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "dir2/file1.txt" 
  content = "This is file1 in dir2." 
}

resource "aws_s3_object" "file2_in_dir2" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "dir2/file2.txt" 
  content = "This is file2 in dir2." 
}


# IAM Role for EC2 to access S3
resource "aws_iam_role" "ec2_role" {
  name = "s3_service_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  depends_on = [
    aws_s3_bucket.example_bucket
  ]
}

# IAM Policy for S3 Access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy"
  description = "Policy to allow EC2 instance to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.example_bucket.arn,
          "${aws_s3_bucket.example_bucket.arn}/*"
        ]
      }
    ]
  })
  depends_on = [
    aws_s3_bucket.example_bucket
  ]
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
  depends_on = [
    aws_s3_bucket.example_bucket
  ]
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "s3_service_ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
  depends_on = [
    aws_s3_bucket.example_bucket
  ]
}

# Security Group for EC2
resource "aws_security_group" "instance_sg" {
  name_prefix = "s3_service_sg"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [
    aws_s3_bucket.example_bucket
  ]
}

# EC2 Instance
resource "aws_instance" "s3_service_instance" {
  ami                    = "ami-0453ec754f44f9a4a"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups        = [aws_security_group.instance_sg.name]
  user_data              = file("s3_service_ec2_userdata.sh")

  tags = {
    Name = "S3-Service-Instance"
  }
  depends_on = [
    aws_s3_bucket.example_bucket
  ]
}

# Outputs


output "instance_public_ip" {
  value = aws_instance.s3_service_instance.public_ip
  depends_on = [
    aws_s3_bucket.example_bucket
  ]
}
