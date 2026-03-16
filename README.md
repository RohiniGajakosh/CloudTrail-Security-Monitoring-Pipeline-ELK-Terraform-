# CloudTrail-Security-Monitoring-Pipeline-ELK-Terraform-

This project implements a cloud security monitoring pipeline that captures AWS API activity and sends it to the ELK stack for analysis and visualization.

The infrastructure is provisioned using Terraform, and the observability stack runs using Docker Compose.

The pipeline processes AWS CloudTrail logs and provides searchable dashboards for monitoring AWS activity.

# Technologies Used

Terraform
Docker & Docker Compose
AWS CloudTrail
Amazon S3
Amazon SQS
Logstash
Elasticsearch
Kibana

# How It Works

AWS CloudTrail records all API activity in the AWS account.
CloudTrail stores logs in an S3 bucket.
When a new log file is uploaded, S3 generates an event notification.
The event is sent to an SQS queue.
Logstash polls the queue and retrieves the S3 object path.
Logstash downloads and parses the CloudTrail log file.
Parsed logs are indexed in Elasticsearch.
Kibana provides dashboards for searching and visualizing AWS activity.

# Prerequisites

Before running the project:
Install Terraform
Install Docker
Configure AWS CLI credentials
aws configure
