#------------------------------------------------------
# Lambda archive and function
#------------------------------------------------------
data "archive_file" "localfile_hello_lambda" {
  type              = "zip"
  source_file       = "modules/lambda/lambda_code/app.py"
  output_path       = "modules/lambda/lambda_code/app.py.zip"
}

resource "aws_lambda_function" "s3_event_lambda_function" {
  function_name     = "${var.project}_${var.env}_s3_event_lambda"
  filename          = data.archive_file.localfile_hello_lambda.output_path
  source_code_hash  = data.archive_file.localfile_hello_lambda.output_base64sha256
  role              = aws_iam_role.iam_for_hello_lambda.arn
  handler           = "app.lambda_handler"
  runtime           = "python3.8"
  timeout           = 600
}

#------------------------------------------------------
# Lambda Permission for s3 bucket
#------------------------------------------------------
resource "aws_lambda_permission" "bucket_lambda_permission" {
   statement_id     = "AllowExecutionFromS3Bucket"
   action           = "lambda:InvokeFunction"
   function_name    = aws_lambda_function.s3_event_lambda_function.arn
   principal        = "s3.amazonaws.com"
   source_arn       = var.s3_bucket.arn
}

#------------------------------------------------------
# Notification event s3 to lambda function
#------------------------------------------------------
resource "aws_s3_bucket_notification" "lambda_bucket_notification" {
   bucket                = var.s3_bucket.id
   lambda_function {
     lambda_function_arn = aws_lambda_function.s3_event_lambda_function.arn
     events              = ["s3:ObjectCreated:*"]
   }
   depends_on            = [ aws_lambda_permission.bucket_lambda_permission ]
}
#------------------------------------------------------
# IAM role - policy - policy_attachment
#------------------------------------------------------
resource "aws_iam_role" "iam_for_hello_lambda" {
  name               = "${var.project}_${var.env}_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_hello_lambda" {
  name        = "${var.project}_${var.env}_iam_policy"
  description = "Add logs and s3 permission"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "s3:ListBucket",
       "s3:GetObject",
       "s3:CopyObject",
       "s3:HeadObject"
     ],
     "Effect": "Allow",
     "Resource": [
       "${var.s3_bucket.arn}"
     ]
   },
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Effect": "Allow",
     "Resource": "*"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.iam_for_hello_lambda.id
  policy_arn = aws_iam_policy.iam_policy_for_hello_lambda.arn
}