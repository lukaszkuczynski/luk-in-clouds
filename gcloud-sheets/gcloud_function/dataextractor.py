def to_action_items(raw_sheet_data):
    result_rows = []
    headers = raw_sheet_data[0]
    for row in raw_sheet_data[1:]:
        row_edited = dict(zip(headers, row))
        row_edited = {k: v for (k, v) in row_edited.items() if k}
        result_rows.append(row_edited)
    return result_rows


if __name__ == '__main__':
    # vars = {"users": [{"link":"300300300","caption":"caption"}]}
    # html = get_template_fill(vars)
    # print(html)
    from raw_test_elements import values as raw_test_elements
    items = to_action_items(raw_test_elements)
    print(items)
