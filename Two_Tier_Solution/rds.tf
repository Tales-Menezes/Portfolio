# Create a subnet group for the RDS DB spead between the 2 existing private subnets
resource "aws_db_subnet_group" "subnet_group" {
  name = var.db_subnet
  subnet_ids = [
    aws_subnet.private_subnets["private_subnet_1"].id,
    aws_subnet.private_subnets["private_subnet_2"].id
  ]
}

# Create a database in MySQL version 5.7
resource "aws_db_instance" "db_rds" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  # Prevent snapshot upon deletion. Backup is not necessary in this case. 
  skip_final_snapshot    = true 
}