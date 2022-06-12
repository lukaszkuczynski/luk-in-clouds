import os
from datetime import datetime
from google.cloud import datastore
from datetime import datetime
from dataextractor import to_action_items, to_original_dict, validate_action_items
from printer import get_html_page
import time
from googleapiclient.discovery import build
import google.auth


def store_data(datastore_client, dt, data):
    index_name = os.getenv("INDEX_NAME")
    key_value = int(time.time_ns() / 1000)
    entity = datastore.Entity(key=datastore_client.key(index_name, key_value))
    entity.update({
        'timestamp': dt,
        'data': data
    })
    datastore_client.put(entity)
    return key_value


def entrypoint(request):

    datastore_client = datastore.Client()

    credentials, project_id = google.auth.default(
        scopes=['https://www.googleapis.com/auth/spreadsheets'])

    service = build('sheets', 'v4', credentials=credentials)
    spreadsheet_id = os.getenv("SPREADSHEET_ID")
    sheet_range = os.getenv("SHEET_RANGE")
    mailsender_function_url = os.getenv("SENDER_FUNCTION_URL")
    sheet = service.spreadsheets()
    range_str = sheet_range
    print(f"Getting range {range_str}")
    result = sheet.values().get(spreadsheetId=spreadsheet_id, range=range_str).execute()
    values_all = result.get('values', [])
    dtnow = datetime.now()
    original_rows = to_original_dict(values_all)
    action_items = to_action_items(original_rows)
    validation_result = validate_action_items(action_items)
    schedule_id = store_data(datastore_client, dtnow, action_items)
    full_url = f"{mailsender_function_url}?schedule_id={schedule_id}"
    context = {
        "creation_time": datetime.now(),
        "original_rows": original_rows,
        "action_items": action_items,
        "mailsender_function_url": full_url,
        "validation_result": validation_result
    }
    page = get_html_page(context)
    return page
