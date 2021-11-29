terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

# SSH key - external
resource "aws_key_pair" "ssh-key" {
  key_name = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzx0yDAl/5gcgdtGg3lBT8CDgX7L3Aq4ESCbAL8Qy4Nv6jez6JRD4vvA3rGZmP5MuBzC16gBUIGqIeu53Re451on6ZVsYcx5mQYAMhxWsnxdIiQxX7JvrR7E2hVlnG6NXC5N5bAOx1iQyzM3qgsA77QI9v1gIfp1OA8wPd1tLYiPpfxRCAWigZlAkLHfC+VFs+3dZHgxrPp2Oa1DgNenWg7FtEFvVgH/Yd1VbihftqSuQGt5+4VrOghS5kiAoVdrDzEQnVfhuQoackfXjSdHlptxSI0mStHbRGH/h638bv17NtWty2qvSD30Kc8WsA15aj8FuYbWsMZpOUoMkodsNSeZ9e8mfdBSuP/pvnnZidKhzWEB5RVlOg+9LIm0tOPoxtY7Mh+4alWdgyi+SSbpojiTVwht575JGLUfGC9t8Wg5384d5CFz5rKvRvxWuPeZoInNfbLULHAAwsqd7Yw/JVHhecShhriOIvndieqhT7mwJFn+cJhPv/lLiFApivS5M= root@f35dev"
}

# Create vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

# Create Custom Route Table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

# Create a Subnet 
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tcp_22_80_443_8080"
  }
}

# Create a network interface with an ip in the subnet
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

resource "aws_network_interface" "app-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.51"]
  security_groups = [aws_security_group.allow_web.id]

}

resource "aws_network_interface" "db-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.52"]
  security_groups = [aws_security_group.allow_web.id]

}

# Assign an elastic IP to the network interface
resource "aws_eip" "web_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

resource "aws_eip" "app_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.app-server-nic.id
  associate_with_private_ip = "10.0.1.51"
  depends_on                = [aws_internet_gateway.gw]
}

resource "aws_eip" "db_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.db-server-nic.id
  associate_with_private_ip = "10.0.1.52"
  depends_on                = [aws_internet_gateway.gw]
}

# Create an instance (web)
resource "aws_instance" "web-server-instance" {
  ami               = "ami-0b0af3577fe5e3532"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "ssh-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  tags = {
    Name = "web-server"
  }
}

# Create an instance (application)
resource "aws_instance" "application-server-instance" {
  ami               = "ami-0b0af3577fe5e3532"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "ssh-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.app-server-nic.id
  }

  tags = {
    Name = "application-server"
  }
}

# Create an instance (database)
resource "aws_instance" "database-server-instance" {
  ami               = "ami-0b0af3577fe5e3532"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "ssh-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.db-server-nic.id
  }

  tags = {
    Name = "database-server"
  }
}

output "web_server_public_ip" {
  value = aws_instance.web-server-instance.public_ip
}

output "web_server_private_ip" {
  value = aws_instance.web-server-instance.private_ip
}

output "app_server_private_ip" {
  value = aws_instance.application-server-instance.private_ip
}

output "db_server_private_ip" {
  value = aws_instance.database-server-instance.private_ip
}
