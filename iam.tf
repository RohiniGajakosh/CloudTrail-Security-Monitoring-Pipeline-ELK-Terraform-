resource "aws_iam_role" "elk_role" {
  name = "elk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# ── Policy: CloudTrail S3 read ─────────────────────────────────────────────
resource "aws_iam_policy" "cloudtrail_policy" {
  name = "cloudtrail-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "CloudTrailS3Access"
      Effect = "Allow"
      Action = ["s3:ListBucket", "s3:GetObject"]
      Resource = [
        aws_s3_bucket.cloudtrail_logs.arn,
        "${aws_s3_bucket.cloudtrail_logs.arn}/*"
      ]
    }]
  })
}

# ── Policy: SSM — publish and read the swarm join token ───────────────────
resource "aws_iam_policy" "ssm_swarm_policy" {
  name = "ssm-swarm-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMSwarmTokenReadWrite"
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DeleteParameter"
        ]
        Resource = "arn:aws:ssm:ap-south-1:*:parameter/elk-swarm/*"
      },
      {
        Sid      = "KMSDecryptSSMSecureString"
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elk_attach_cloudtrail" {
  role       = aws_iam_role.elk_role.name
  policy_arn = aws_iam_policy.cloudtrail_policy.arn
}

resource "aws_iam_role_policy_attachment" "elk_attach_ssm" {
  role       = aws_iam_role.elk_role.name
  policy_arn = aws_iam_policy.ssm_swarm_policy.arn
}

resource "aws_iam_instance_profile" "elk_profile" {
  name = "elk-instance-profile"
  role = aws_iam_role.elk_role.name
}
