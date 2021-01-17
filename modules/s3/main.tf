resource "aws_s3_bucket" "event_lambda_s3_bucket" {
  bucket        = "example-event-bucket"
  force_destroy = true
}
