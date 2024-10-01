
# ############################################################################################################# #
# This file creates a security group for the web application.                                                   #
# It allows TCP traffic from anywhere via port 80 and 443.                                                      #
# It creates a security group for SSH access via port 22  to the EC2 to allow the installation of the app.      #
# ############################################################################################################# #

# Create a security group to allow TCP access to the EC2 instance via port 80 and 443
resource "aws_security_group" "web_app_vpc" {
  name        = "web-app-sg-${terraform.workspace}"
  vpc_id      = aws_vpc.vpc.id
  description = "Web Traffic via TCP"
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create a security group to allow access to the EC2 instance via SSH
resource "aws_security_group" "ingress_ssh" {
  name   = "allow-all-ssh"
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}