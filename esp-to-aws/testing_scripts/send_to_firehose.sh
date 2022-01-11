msg='{"msg": "test_json"}'
base64_msg=$(echo $msg | base64)
aws firehose put-record \
    --delivery-stream-name esp2aws-delivery-stream \
    --record "{\"Data\":\"${base64_msg}\"}"