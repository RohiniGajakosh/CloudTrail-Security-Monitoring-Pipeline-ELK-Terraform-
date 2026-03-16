resource "aws_iam_role" "elk_role" {

  name = "elk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "elk_policy" {

  name = "elk-cloudtrail-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = aws_sqs_queue.cloudtrail_queue.arn
      },

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "elk_attach" {

  role       = aws_iam_role.elk_role.name
  policy_arn = aws_iam_policy.elk_policy.arn

}

resource "aws_iam_instance_profile" "elk_profile" {

  name = "elk-instance-profile"
  role = aws_iam_role.elk_role.name

}