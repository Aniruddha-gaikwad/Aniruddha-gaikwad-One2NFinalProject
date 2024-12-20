# Implementation Details <br>
# Part 1: HTTP Service
The HTTP service is implemented in Python. The service exposes the following endpoint:

## Endpoint:<br>
`GET /list-bucket-content/<path>`

## Behavior:<br>

- Returns the content of the S3 bucket at the specified <path>.
- If no path is specified, it returns the top-level contents of the bucket.
- Non-existing paths or errors are handled gracefully with appropriate HTTP error codes and messages.

## Examples:

## If the bucket contains:

Copy code <br>
|_ dir1 <br>
|_ dir2 <br>
> |_ file1 <br>
> |_ file2 <br>

GET /list-bucket-content → {"content": ["dir1", "dir2", "file1", "file2"]} <br>
GET /list-bucket-content/dir1 → {"content": []} <br>
GET /list-bucket-content/dir2 → {"content": []} <br>
For a non-existing path: <br>

`GET /list-bucket-content/non-existing → {"error": "Path not found"} (HTTP 404)`

# Part 2: Infrastructure as Code

## Provider Configuration
The AWS provider is set to use the us-east-1 region.

```bash
provider "aws" {
  region = "us-east-1"
}
```

# S3 Bucket
## Creates an S3 bucket named anigaikwadbucket16. Tags are added for better resource identification.

```bash
resource "aws_s3_bucket" "example_bucket" {
  bucket = "anigaikwadbucket16" 
  tags = {
    Name        = "S3 Bucket"
    Environment = "Development"
  }
}
```
# S3 Bucket Objects

Creates placeholder directories dir1 and dir2.<br>
Adds files file1.txt and file2.txt to dir2 with sample content.<br>

# IAM Role and Policy

- An IAM role s3_service_ec2_role is created to allow EC2 instances to access S3.
- An IAM policy grants the role permissions to list, get, put, and delete objects in the bucket.
- The policy is attached to the role, and an instance profile is created.

# Security Group
Configures an ingress rule to allow traffic on `port 5000` (used by the HTTP service) and an egress rule to allow all outbound traffic.

# EC2 Instance

- Provisions a `t2.micro` EC2 instance.
- Associates the IAM instance profile for S3 access.
- Deploys the HTTP service using the user_data script (s3_service_ec2_userdata.sh).
- The script file is expected to set up and start the HTTP service on port 5000.

# Outputs
Outputs the public IP of the EC2 instance for easy access.

![Screenshot 2024-12-08 000136](https://github.com/user-attachments/assets/848e780f-d555-48da-8e19-5c68c4e2e9c6)

![Screenshot 2024-12-08 000158](https://github.com/user-attachments/assets/fd3b88a0-f807-4a9c-a0d7-2d4b499fe05f)

![Screenshot 2024-12-08 000221](https://github.com/user-attachments/assets/35be8568-e685-4d2c-abb5-cd96e69379c8)




