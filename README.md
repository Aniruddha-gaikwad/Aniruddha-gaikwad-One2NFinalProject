Implementation Details
Part 1: HTTP Service
The HTTP service is implemented in Python. The service exposes the following endpoint:

Endpoint:
GET /list-bucket-content/<path>

Behavior:

Returns the content of the S3 bucket at the specified <path>.
If no path is specified, it returns the top-level contents of the bucket.
Non-existing paths or errors are handled gracefully with appropriate HTTP error codes and messages.
Examples:

If the bucket contains:

Copy code
|_ dir1
|_ dir2
|_ file1
|_ file2
GET /list-bucket-content → {"content": ["dir1", "dir2", "file1", "file2"]}
GET /list-bucket-content/dir1 → {"content": []}
GET /list-bucket-content/dir2 → {"content": []}
For a non-existing path:

GET /list-bucket-content/non-existing → {"error": "Path not found"} (HTTP 404)

Part 2: Infrastructure as Code

Provider Configuration
The AWS provider is set to use the us-east-1 region.

provider "aws" {
  region = "us-east-1"
}
S3 Bucket
Creates an S3 bucket named anigaikwadbucket16. Tags are added for better resource identification.


resource "aws_s3_bucket" "example_bucket" {
  bucket = "anigaikwadbucket16" 
  tags = {
    Name        = "S3 Bucket"
    Environment = "Development"
  }
}
S3 Bucket Objects

Creates placeholder directories dir1 and dir2.
Adds files file1.txt and file2.txt to dir2 with sample content.
IAM Role and Policy

An IAM role s3_service_ec2_role is created to allow EC2 instances to access S3.
An IAM policy grants the role permissions to list, get, put, and delete objects in the bucket.
The policy is attached to the role, and an instance profile is created.
Security Group
Configures an ingress rule to allow traffic on port 5000 (used by the HTTP service) and an egress rule to allow all outbound traffic.

EC2 Instance

Provisions a t2.micro EC2 instance.
Associates the IAM instance profile for S3 access.
Deploys the HTTP service using the user_data script (s3_service_ec2_userdata.sh).
The script file is expected to set up and start the HTTP service on port 5000.
Outputs
Outputs the public IP of the EC2 instance for easy access.
