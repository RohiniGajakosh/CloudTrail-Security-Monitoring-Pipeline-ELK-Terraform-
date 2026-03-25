resource "aws_vpc" "elkvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ELK-VPC"
  }
}

resource "aws_subnet" "ELK-Public-Subnet" {
  vpc_id     = aws_vpc.elkvpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "ELK-Public-Subnet"
  }
}

resource "aws_internet_gateway" "elk_igw" {
  vpc_id = aws_vpc.elkvpc.id
  tags = {
    Name = "ELK-IGW"
  }
}

resource "aws_route_table" "elk_route_table" {
  vpc_id = aws_vpc.elkvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.elk_igw.id
  }
  tags = {
    Name = "ELK-Route-Table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.ELK-Public-Subnet.id
  route_table_id = aws_route_table.elk_route_table.id
}
