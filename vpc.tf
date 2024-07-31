provider "aws" {
    region = "us-east-2"
}

# resource "aws_key_pair" "Vlad1" {
#   key_name   = var.key_name
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCieZunf8h2XxSG4ISRlSKft/kbJWUIWOTKDP40TkHHD6hNAwgjeciRU1qcnnpkCwRM0taMNsMJd+xPKi2n+WK0cz62fO4M9o3R4/m7mVlCLbIe9nbBv1Rew1Ga46aNgarTh32I/VKo5arWzFsE3afJ6m1hW21klqydsxTGKz4o2jok40dcELYjEouf2EMl0c6E0Y9c+/pMbY6HnlGeZB6k7gM4fRJZzALs+nKUEdhuU1EKuaNGgdhogGI6J10FaxQZzWxFL3nxajfwBwzjjG9HdXqfnZ+yl1JMp0qyGonjott3fGbEUT9p0Li3iqF3sBVy5mrzrYIMXpJbQf5NYKpV8gjrihjiQ5PkUm02C18Tie1/gR97xJS91gMhSbHgcgE25B3RBnSl+UpaHnet8qJvbhcLcVF29kR1T8B7Yr7e56lkkcMFCJjoK2nwMfuswkm9aKSCoohxV3t9+i7jTc2SNOOlQLsqLKDhCMp+pHZWTFSJh78+Vqe5G7vc9TC1ug0= kakaz@MSI"
# }

#===========================================================================

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
    tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

#===============================================================================

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}

resource "aws_route_table_association" "public_routes" {
  count = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
}

#==============================================================================

resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs)
  domain = "vpc"
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}

# resource "aws_network_interface" "multi-ip" {
#   subnet_id   = aws_subnet.main.id
#   private_ips = ["10.0.0.10", "10.0.0.11"]
# }

# resource "aws_eip" "one" {
#   domain                    = "vpc"
#   network_interface         = aws_network_interface.multi-ip.id
#   associate_with_private_ip = "10.0.0.10"
# }

# resource "aws_eip" "two" {
#   domain                    = "vpc"
#   network_interface         = aws_network_interface.multi-ip.id
#   associate_with_private_ip = "10.0.0.11"
# }

resource "aws_nat_gateway" "nat" {
  count = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}

#====================================================================================

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.env}-route-private-subnets-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_routes" {
  count = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
}

#=====================================================================================

