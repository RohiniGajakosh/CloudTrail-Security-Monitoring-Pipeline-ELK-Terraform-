resource "aws_cloudtrail" "main_trail" {
  name                          = "demo-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
}