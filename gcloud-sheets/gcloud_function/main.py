import os
from datetime import datetime
from googleapiclient.discovery import build
import google.auth


def entrypoint(request):

    credentials, project_id = google.auth.default(
        scopes=['https://www.googleapis.com/auth/spreadsheets'])

    service = build('sheets', 'v4', credentials=credentials)
    spreadsheet_id = os.getenv("SPREADSHEET_ID")

    start_cell = "A1"
    end_cell = "C3"

    sheet = service.spreadsheets()
    range_str = f"{start_cell}:{end_cell}"
    print(f"Getting range {range_str}")
    result = sheet.values().get(spreadsheetId=spreadsheet_id, range=range_str).execute()
    values_all = result.get('values', [])
    for value in values_all:
        print(value)
    return str(values_all)


if __name__ == '__main__':
    # vars = {"users": [{"link":"300300300","caption":"caption"}]}
    # html = get_template_fill(vars)
    # print(html)
    phonebook = read_phonebook()
    nn = name_numbers_dict("name1", phonebook)
    print(nn)
