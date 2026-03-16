resource "aws_instance" "elk_server" {
  ami           = "ami-0f559c3642608c138"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.elk_profile.name
  vpc_security_group_ids = [aws_security_group.elk_sg.id]
  key_name      = "awskey"
  associate_public_ip_address =  true
  subnet_id    = aws_subnet.public_subnet.id
  user_data = file("${path.module}/userdata.sh")
  tags = {
    Name = "ELK-Server"
  }
  
}

resource "aws_vpc" "elkvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.elkvpc.id
  cidr_block        = "10.0.1.0/24" 
}

resource "aws_internet_gateway" "elk_igw" {
    vpc_id = aws_vpc.elkvpc.id
}

resource "aws_route_table" "elk_route_table" {
    vpc_id = aws_vpc.elkvpc.id

    route {
        cidr_block = "10.0.0.0/0"
        gateway_id = aws_internet_gateway.elk_igw.id
    }
}

resource "aws_route_table_association" "public_subnet_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.elk_route_table.id
}   

resource "aws_security_group" "elk_sg" {
  name        = "elk_security_group"
  description = "Security group for ELK server"
  vpc_id      = aws_vpc.elkvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}