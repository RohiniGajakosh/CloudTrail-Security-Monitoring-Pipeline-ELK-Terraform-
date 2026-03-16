resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "cloudtrail-logs-bucket-123456789"
  tags = {
    Name = "CloudTrail Logs Bucket"
  } 
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid = "AWSCloudTrailAclCheck"

        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:GetBucketAcl"

        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },

      {
        Sid = "AWSCloudTrailWrite"

        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  queue {
    queue_arn = aws_sqs_queue.cloudtrail_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}