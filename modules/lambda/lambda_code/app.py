import boto3

s3_client = boto3.client('s3')


def lambda_handler(event, context):

    initial_event_bucket = event['Records'][0]['s3']['bucket']['name']
    print(f"Bucket, {initial_event_bucket}")

    key_file_name = event['Records'][0]['s3']['object']['key']
    print(f"File name, {key_file_name}")
