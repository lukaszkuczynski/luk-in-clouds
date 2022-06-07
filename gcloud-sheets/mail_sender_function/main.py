import os
from datetime import datetime
from unittest import result
from google.cloud import datastore
import json

datastore_client = datastore.Client()


def get_schedule_by_id(schedule_id):
    index_name = os.getenv("INDEX_NAME")
    schedule_key = datastore_client.key(index_name, int(schedule_id))
    schedule = datastore_client.get(schedule_key)
    return schedule['data']


def entrypoint(request):
    if request.method == 'OPTIONS':
        # Allows GET requests from any origin with the Content-Type
        # header and caches preflight response for an 3600s
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }

        return ('', 204, headers)

    request_args = request.args
    if request_args and 'schedule_id' in request_args:
        schedule_id = request_args['schedule_id']
    else:
        raise Exception("schedule_id key is required")

    schedule = get_schedule_by_id(schedule_id)
    print(schedule)

    # Set CORS headers for the main request
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
    }

    sent_result = {
        "result": True,
        "data": schedule
    }
    sent_resp = json.dumps(sent_result)

    return (sent_resp, 200, headers)
