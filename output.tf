output "sqs_queue_url" {
  value = aws_sqs_queue.cloudtrail_queue.id
}

output "manager_public_ip" {
  description = "SSH into the manager and check: docker node ls"
  value       = aws_instance.swarm_manager.public_ip
}

output "worker_public_ips" {
  description = "Worker node public IPs"
  value       = aws_instance.swarm_worker[*].public_ip
}

output "kibana_url" {
  description = "Open Kibana in your browser"
  value       = "http://${aws_instance.swarm_worker[0].public_ip}:5601"
}
