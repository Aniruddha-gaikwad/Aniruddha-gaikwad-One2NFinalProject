#!/bin/bash
# Update system packages
sudo yum update -y

sudo dnf install python3

sudo dnf install python3-pip -y

pip3 install flask boto3

sudo yum install git -y

git clone https://github.com/Aniruddha-gaikwad/One2NFinalProject.git
cd One2NFinalProject

# Start the Flask application
python3 app.py
