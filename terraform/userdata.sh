#!/bin/bash

yum update -y
yum install docker -y
service docker start
usermod -a -G docker ec2-user
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cd /home/ec2-user/elk
git clone https://github.com/yourusername/cloudtrail-elk.git
cd cloudtrail-elk
docker-compose up -d
