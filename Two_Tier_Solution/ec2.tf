
# ############################################################################################################# #
# This file searches for the latest Ubuntu 20.04 AMI Image from Amazon AMI Catalog.                             #
# Generate a private key pair to connect to EC2 Instance via SSH.                                               #
# Launch one EC2 instance in EACH public subnet using the latest Ubuntu 20.04 AMI image.                        #
#   Connect to EC2 via SSH using the private key generated.                                                     #
#   Use 'local-exec' provisioner to execute commands inside the EC2 instance.                                   #
#   Download the application from a git repository and install it remotely.                                     #
# ############################################################################################################# #

# Terraform Data Block - To Lookup Latest Ubuntu 20.04 AMI Image
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Generate a private key pair to connect to EC2 Instance via SSH
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated" {
  key_name   = "MyAWSKey"
  public_key = tls_private_key.generated.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "MyAWSKey.pem"
}

# Terraform Resource Block - To build two EC2 instances. One in each public subnet
resource "aws_instance" "app_server" {
  for_each      = aws_subnet.public_subnets
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type
  subnet_id     = aws_subnet.public_subnets[each.key].id # each public subnet

  # Allow access from SSH and from the ELB only
  security_groups = [
    aws_security_group.ingress_ssh.id,
    aws_security_group.web_app_vpc.id
  ]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated.key_name

  # Connect to the EC2 via SSH
  connection {
    user        = "ubuntu"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
  }

  # Use `local-exec` provisioner to execute commands inside the EC2 instance. 
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }

  # Download the application from a git repository and install it remotely. 
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /tmp",
      "sudo git clone https://github.com/hashicorp/demo-terraform-101 /tmp",
      "sudo sh /tmp/assets/setup-web.sh",
    ]
  }

  # Prevents the EC2 being replaced when security group changes. 
  # This prevents the replacement of the EC2 everytime the command terraform apply is used. 
  lifecycle {
    ignore_changes = [security_groups]
  }
  tags = local.common_tags
}