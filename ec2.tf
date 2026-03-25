# ──────────────────────────────────────────────
# Manager node (index 0) — initializes the swarm,
# assigns node labels, deploys the stack
# ──────────────────────────────────────────────
resource "aws_instance" "swarm_manager" {
  ami                         = "ami-0f559c3642608c138"
  instance_type               = "t3.small"
  iam_instance_profile        = aws_iam_instance_profile.elk_profile.name
  vpc_security_group_ids      = [aws_security_group.elk_sg.id]
  key_name                    = "awskey"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.ELK-Public-Subnet.id
  user_data = templatefile("${path.module}/userdata-manager.sh.tftpl", {
    bucket_name = aws_s3_bucket.cloudtrail_logs.id
  })

  tags = {
    Name = "ELK-Swarm-Manager"
    Role = "manager"
  }
}

# ──────────────────────────────────────────────
# Worker nodes (2) — join the swarm, get labelled
# via their own userdata after manager is ready
# ──────────────────────────────────────────────
resource "aws_instance" "swarm_worker" {
  count                       = 2
  ami                         = "ami-0f559c3642608c138"
  instance_type               = "t3.small"
  iam_instance_profile        = aws_iam_instance_profile.elk_profile.name
  vpc_security_group_ids      = [aws_security_group.elk_sg.id]
  key_name                    = "awskey"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.ELK-Public-Subnet.id

  # Pass manager private IP and worker index so each worker
  # knows where to join and what label to request
  user_data = templatefile("${path.module}/userdata-worker.sh.tftpl", {
    manager_private_ip = aws_instance.swarm_manager.private_ip
    worker_index       = count.index  # 0 → kibana, 1 → logstash
  })

  # Workers must start AFTER the manager so the SSM parameter
  # holding the join token is already published
  depends_on = [aws_instance.swarm_manager]

  tags = {
    Name = "ELK-Swarm-Worker-${count.index + 1}"
    Role = count.index == 0 ? "kibana" : "logstash"
  }
}


resource "aws_security_group" "elk_sg" {
  name        = "elk_security_group"
  description = "Security group for ELK swarm nodes"
  vpc_id      = aws_vpc.elkvpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kibana UI"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Elasticsearch HTTP"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Docker Swarm manager control plane"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Docker Swarm gossip TCP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Docker Swarm gossip UDP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Docker overlay network (VXLAN)"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
