#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import boto3
from botocore.vendored import requests

def send_response_to_cfn(event, context, status):
    response_body = {'Status': status,
                     'Reason': 'Log stream name: ' + context.log_stream_name,
                     'PhysicalResourceId': context.log_stream_name,
                     'StackId': event.get('StackId'),
                     'RequestId': event.get('RequestId'),
                     'LogicalResourceId': event.get('LogicalResourceId'),
                     'Data': json.loads("{}")}

    if status != 'PASS':
        requests.put(event['ResponseURL'], data=json.dumps(response_body))
    else:
        return True


def runner(event, context):
    request_type = event.get('RequestType')
    if request_type != 'Delete':
        send_response_to_cfn(event, context, "PASS")

    resouce_properties = event.get('ResourceProperties')
    bucket = resouce_properties.get('BucketName')
    if request_type == 'Delete' and bucket is None:
        send_response_to_cfn(event, context, "FAILED")
        raise

    try:
        s3 = boto3.resource('s3')
        bucket = s3.Bucket(bucket)
        for obj in bucket.objects.filter():
            s3.Object(bucket.name, obj.key).delete()

        send_response_to_cfn(event, context, "SUCCESS")
    except Exception as e:
        print(e)
        send_response_to_cfn(event, context, "FAILED")
