import base64
import json
from datetime import datetime

print('Loading function')


def lambda_handler(event, context):
    output = []

    for record in event['records']:
        print(record['recordId'])
        payload = base64.b64decode(record['data']).decode('utf-8')
        payload_json = json.loads(payload)
        payload_json["ts"] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        payload_json_text = json.dumps(payload_json)
        print(payload_json_text)
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(payload_json_text.encode('utf-8'))
        }
        output.append(output_record)

    print('Successfully processed {} records.'.format(len(event['records'])))
    return {'records': output}
