# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 80 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "directus port"
    from_port   = 8055
    to_port     = 8055
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker server sg"
  }
}

# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}

# use data source to get a registered amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "key_name" {
  description = "Name of the EC2 key pair"
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = var.key_name

  provisioner "local-exec" {
    command = "chmod 600 ${var.key_name}"
  }
}

# # Create PostgreSQL Database in RDS
# resource "aws_db_instance" "directus_db" {
#   allocated_storage    = 20
#   engine               = "postgres"
#   engine_version       = "13.4"
#   instance_class       = "db.t2.micro"
#   username             = "directus"
#   password             = "directuspassword"
#   parameter_group_name = "default.postgres13"
#   publicly_accessible  = true
#   skip_final_snapshot  = true
#   vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

#   # Specify the DB subnet group
#   db_subnet_group_name = aws_db_subnet_group.default.name

#   # Backup retention and window settings
#   backup_retention_period = 7
#   backup_window           = "03:00-06:00"

#   # Maintenance window settings
#   maintenance_window = "Mon:00:00-Mon:03:00"

#   tags = {
#     Name = "directus-rds"
#   }
# }

# # Create a Subnet Group for RDS
# resource "aws_db_subnet_group" "default" {
#   name       = "directus-db-subnet-group"
#   subnet_ids = [aws_default_subnet.default_az1.id]

#   tags = {
#     Name = "directus-db-subnet-group"
#   }
# }


# launch the ec2 instance
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-09efc42336106d2f2"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = aws_key_pair.key_pair.key_name

  tags = {
    Name = "Directus Docker server"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo systemctl enable sshd
    sudo systemctl start sshd
  EOF

  provisioner "local-exec" {
    command = "touch dynamic_inventory.ini"
  }
}


data "template_file" "inventory" {
  template = <<-EOT
    [ec2_instances]
    ${aws_instance.ec2_instance.public_ip} ansible_user=ec2-user ansible_private_key_file=${path.cwd}/${var.key_name}
    EOT
}

resource "local_file" "dynamic_inventory" {
  depends_on = [aws_instance.ec2_instance]

  filename = "dynamic_inventory.ini"
  content  = data.template_file.inventory.rendered

  provisioner "local-exec" {
    command = "chmod 600 ${local_file.dynamic_inventory.filename}"
  }
}

resource "null_resource" "run_ansible" {
  depends_on = [local_file.dynamic_inventory]

  provisioner "local-exec" {
    command     = "ansible-playbook -i dynamic_inventory.ini install-docker-ansible.yml"
    working_dir = path.module
  }
}
