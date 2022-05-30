import os
from datetime import datetime
from googleapiclient.discovery import build
import google.auth
from google.cloud import datastore
from datetime import datetime
from dataextractor import to_action_items

datastore_client = datastore.Client()


def store_data(dt, data):
    index_name = os.getenv("INDEX_NAME")
    entity = datastore.Entity(key=datastore_client.key(index_name))
    entity.update({
        'timestamp': dt,
        'data': data
    })
    datastore_client.put(entity)


def entrypoint(request):

    credentials, project_id = google.auth.default(
        scopes=['https://www.googleapis.com/auth/spreadsheets'])

    service = build('sheets', 'v4', credentials=credentials)
    spreadsheet_id = os.getenv("SPREADSHEET_ID")
    sheet_range = os.getenv("SHEET_RANGE")
    sheet = service.spreadsheets()
    range_str = sheet_range
    print(f"Getting range {range_str}")
    result = sheet.values().get(spreadsheetId=spreadsheet_id, range=range_str).execute()
    values_all = result.get('values', [])
    dtnow = datetime.now()
    processed_rows = to_action_items(values_all)
    store_data(dtnow, processed_rows)
    return str(processed_rows)
