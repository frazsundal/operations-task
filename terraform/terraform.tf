
variable "database_master_password" {}

provider "aws" {
  profile = "default"
  region = "us-west-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "rds-vpc"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id  

  tags = {
    Name = "igt"
  }
}

resource "aws_subnet" "public_west1a" {
  vpc_id     = aws_vpc.main.id
  availability_zone = "us-west-1c"
  cidr_block = "172.31.0.0/20"  

  tags = {
    Name = "public-subnet-us-west-1a"
  }
}
resource "aws_subnet" "public_west1b" {
  vpc_id     = aws_vpc.main.id
  availability_zone = "us-west-1b"
  cidr_block = "172.31.48.0/20"  

  tags = {
    Name = "public-subnet-us-west-1b"
  }
}


resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "public-rtb"
  }
}


resource "aws_route" "r" {
  route_table_id            = aws_vpc.main.default_route_table_id
  destination_cidr_block    = "0.0.0.0/0"  
  gateway_id                = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_west1a" {
  subnet_id      = aws_subnet.public_west1a.id
  route_table_id = aws_vpc.main.default_route_table_id
}


resource "aws_security_group" "rds" {
  name        = "rds-db-sg-tf"
  description = "Security group for RDS DB"
  vpc_id      = aws_vpc.main.id

  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  tags = {
    Name = "sg-rds-security-group"
  }
}

resource "aws_db_subnet_group" "def" {
  name       = "rds-subnet-group-tf"
  subnet_ids = [aws_subnet.public_west1a.id,aws_subnet.public_west1b.id]

  tags = {
    Name = "rds-subnet-group-tf"
  }
}


resource "aws_db_instance" "db" {
  identifier           = "rates-db"
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "13.5"  
  instance_class       = "db.t3.micro"
  name                 = "rates"
  username             = "postgres"
  password             = var.database_master_password
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true  
  publicly_accessible  = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.def.name
  availability_zone    = "us-west-1b"
  
  tags = {
    Name = "rates-db"
  }
}


#create parameter store

resource "aws_ssm_parameter" "host" {
  name        = "/database/host"
  description = "This is database host"
  type        = "String"
  value       = aws_db_instance.db.address
}
resource "aws_ssm_parameter" "database_name" {
  name        = "/database/database_name"
  description = "This is database name"
  type        = "String"
  value       = aws_db_instance.db.name
}
resource "aws_ssm_parameter" "user_name" {
  name        = "/database/user_name"
  description = "This is database user name"
  type        = "String"
  value       = aws_db_instance.db.username
}
resource "aws_ssm_parameter" "password" {
  name        = "/database/password"
  description = "This is database password"
  type        = "SecureString"
  value       = var.database_master_password
}