resource "aws_sqs_queue" "cloudtrail_queue" {
  name = "cloudtrail-log-queue"
}

resource "aws_sqs_queue_policy" "s3_sqs_policy" {
  queue_url = aws_sqs_queue.cloudtrail_queue.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = "*"

        Action = "SQS:SendMessage"

        Resource = aws_sqs_queue.cloudtrail_queue.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.cloudtrail_logs.arn
          }
        }
      }
    ]
  })
}