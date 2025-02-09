provider "aws" {
  region = "us-east-1"  # North Virginia
}

terraform {
  backend "s3" {
    bucket = "jen123"   # Your S3 bucket for storing Terraform state
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Fetch the Default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch the Default Public Subnet in Mumbai Region
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Select the first available subnet
data "aws_subnet" "default" {
  id = tolist(data.aws_subnets.default.ids)[0]
}

# Check if the "jenkins" Security Group exists
data "aws_security_group" "jenkins" {
  filter {
    name   = "group-name"
    values = ["jenkins"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create an EC2 Instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-085ad6ae776d8f09c" # Update with the latest AMI ID for North Virginia
  instance_type = "t2.large"
  subnet_id     = data.aws_subnet.default.id
  key_name      = "jenkinskey"  # Use your existing key pair

  vpc_security_group_ids = [
    data.aws_security_group.jenkins.id
  ]

  associate_public_ip_address = true

  tags = {
    Name = "MyEC2Instance"
  }

  # Download the Dockerfile from GitHub
  provisioner "remote-exec" {
    inline = [
      "curl -o /home/ec2-user/Dockerfile https://github.com/REVATHIPENMETSA/Automation-CI-CD/blob/main/dockerfile",
    ]
  }

  # Download the install.sh script from GitHub (if applicable)
  provisioner "remote-exec" {
    inline = [
      "curl -o /home/ec2-user/install.sh https://github.com/REVATHIPENMETSA/Automation-CI-CD/blob/main/install.sh",
      "chmod +x /home/ec2-user/install.sh",
      "sudo /home/ec2-user/install.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/var/lib/jenkins/jenkinskey.pem")  # Path on the Jenkins server
    host        = self.public_ip
  }
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.my_ec2.public_ip
}
