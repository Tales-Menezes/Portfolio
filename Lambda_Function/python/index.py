import json
from watermark_service import handle_generate_watermark

def get_s3_bucket_and_key(event):
    s3_event_record = event['Record'][0]['s3']
    s3_bucket_name = s3_event_record['bucket']['name']
    object_key = s3_event_record['Object']['key']

    return s3_bucket_name, object_key

def lambda_handler(event, context):
    print('event >> ', event)
    print('context >> ', context)
    bucket_name, file_key = get_s3_bucket_and_key(event)
    print('s3_info::bucket >> ', bucket_name, '::key >> ', file_key)
    handle_generate_watermark(bucket_name, file_key)
    print('Image generated and saved on s3!')
    return {
        'statusCode': 200,
        'body': json.dumps('Image generated and saved on s3!')
    }
