output "sqs_queue_url" {
  value = aws_sqs_queue.cloudtrail_queue.id
}