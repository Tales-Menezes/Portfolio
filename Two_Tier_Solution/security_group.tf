
# ############################################################################################################# #
# This file creates the security groups to allow access to the web application.                                 #
# It allows TCP traffic from anywhere to the Elastic Load Balancer via port 80.                                 #
# It only allows TCP traffic from the ELB into the EC2 instances. Protecting the EC2 from public access.        #
# It allows the EC2 instances to connect to the database via TCP port 3306                                      #
# It creates a security group to allow SSH access via port 22 to install the app.                               #
# It grants outbound access to anywhere to all security groups.                                                 #
# ############################################################################################################# #

# Create a security group to allow public access to the Elastic Load Balancer
resource "aws_security_group" "elb_sg" {
  name        = "${terraform.workspace}-elb"
  vpc_id      = aws_vpc.vpc.id
  description = "Traffic from Web to ELB"
  tags        = local.common_tags
}
# Create a security group to allow ELB to communicate with EC2 instance via port 80
resource "aws_security_group" "web_app_vpc" {
  name        = "${terraform.workspace}-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Traffic from ELB to EC2"
  tags        = local.common_tags
}
# Create a security group to allow the EC2 instances to connect to the database
resource "aws_security_group" "db_sg" {
  name        = "${terraform.workspace}-db"
  vpc_id      = aws_vpc.vpc.id
  description = "Traffic from EC2 to DB"
  tags        = local.common_tags
}
# Create a security group to allow access to the EC2 instance via SSH
resource "aws_security_group" "ingress_ssh" {
  name        = "${terraform.workspace}-ssh"
  vpc_id      = aws_vpc.vpc.id
  description = "Installation access to EC2"
  tags        = local.common_tags
}



# Inbound rule to allow access to the EC2 instances via SSH
resource "aws_security_group_rule" "ingress_ssh" {
  security_group_id = aws_security_group.ingress_ssh.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
# Inbound rule to allow public traffic into the Elastic Load Balancer
resource "aws_security_group_rule" "elb_inbound" {
  security_group_id = aws_security_group.elb_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
# Inbound rule to allow ONLY the ELB to communicate with the EC2 instances. No direct TCP public access
resource "aws_security_group_rule" "ec2_inbound" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id       # Security group of the instances
  source_security_group_id = aws_security_group.web_app_vpc.id # Security group of the EC2 instances
}
# Inbound rule to allow ONLY the EC2 instances to communicate with the database
resource "aws_security_group_rule" "db_inbound" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web_app_vpc.id # Security group of the instances
  source_security_group_id = aws_security_group.elb_sg.id      # Security group of the ALB
}
# Outbound rule dynamically attached to all security groups
resource "aws_security_group_rule" "egress_rule" {
  for_each = {
    "web_app_vpc" : aws_security_group.web_app_vpc.id,
    "elb_sg" : aws_security_group.elb_sg.id,
    "db_sg" : aws_security_group.db_sg.id
    "ingress_ssh" : aws_security_group.ingress_ssh.id
  }

  type              = "egress"
  security_group_id = each.value
  from_port         = 0
  to_port           = 0
  protocol          = "-1"          # All protocols
  cidr_blocks       = ["0.0.0.0/0"] # Allow outbound traffic to everywhere
}