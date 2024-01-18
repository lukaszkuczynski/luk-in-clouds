# pylint disable: missing-function-docstring
import datetime
import json
import logging
import uuid

import azure.functions as func

app = func.FunctionApp()

@app.route(route="HttpExample", auth_level=func.AuthLevel.ANONYMOUS)
@app.queue_output(arg_name="msg", queue_name="outqueue", connection="AzureWebJobsStorage")
def HttpExample(req: func.HttpRequest, msg: func.Out [func.QueueMessage]) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        msg.set(name)
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )

@app.route(route="CreateDynamoDBDocument", auth_level=func.AuthLevel.ANONYMOUS)
@app.cosmos_db_output(arg_name="documents", 
                      database_name="HomeIotLuk",
                      container_name="Events",
                      connection="COSMOSDB_CONNECTION_SETTING")
def CreateDynamoDBDocument(req: func.HttpRequest, documents: func.Out[func.Document]) -> func.HttpResponse:
    logging.info('CreateDynamoDBDocument trigger function processed a request.')
    # json_to_write = func.Document.from_json(req)
    # if not json_to_write:
    event_dict = {
        "id": uuid.uuid1().hex,
        "EventId": uuid.uuid1().hex,
        "event": "something happened",
        "eventTime": datetime.datetime.now().isoformat()
    }
    event_doc = func.Document.from_dict(event_dict)
    resp = documents.set(event_doc)
    print(resp)
    return func.HttpResponse(f"Written to dynamodb")



def validate_event(event_obj):
    is_valid = "device" in event_obj.keys()
    if is_valid:
        print("Object validation successful")
    else:
        print("Validation ERROR!")
    return is_valid

@app.blob_trigger(arg_name="inputblob", path="iotevents/landing/{filename}",
                               connection="AzureWebJobsStorage") 
@app.blob_output(arg_name="outputblob",
                path="iotevents/silver/{filename}",
                connection="AzureWebJobsStorage")
def BlobTrigger(inputblob: func.InputStream, outputblob: func.Out[str]):
    logging.info(f"Python blob trigger function processed blob"
                f"Name: {inputblob.name}"
                f"Blob Size: {inputblob.length} bytes")
    # blob_source_raw_name = msg.get_body().decode('utf-8')
    # with open(blob_source_raw_name,"w+b") as local_blob:
    #     local_blob.write(inputblob.read())
    input_content = inputblob.read()
    input_obj = json.loads(input_content)
    if validate_event(input_obj):
        outputblob.set(input_content)
