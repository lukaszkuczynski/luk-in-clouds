def to_original_dict(raw_sheet_data):
    result_rows = []
    headers = raw_sheet_data[0]
    for row in raw_sheet_data[1:]:
        row_edited = dict(zip(headers, row))
        row_edited = {k: v for (k, v) in row_edited.items() if k}
        result_rows.append(row_edited)
    return result_rows


def get_student_action(row):
    return {
        'mail_to': row['email_task'],
        'topic': 'Your assignment',
        'date': row['date'],
        'item': row['item'],
        'name': row['name'],
        'study': row['study'],
        'template_name': 'student'
    }


def get_assistant_action(row):
    return {
        'mail_to': row['email_assist'],
        'topic': 'Assistant in CLAM',
        'date': row['date'],
        'item': row['item'],
        'name': row['name'],
        'study': row['study'],
        'template_name': 'assistant'
    }


def to_action_items(original_dict):
    all_actions = []
    # first task
    for el in original_dict:
        all_actions.append(get_student_action(el))
    # if some assistants here, create assistant actions
    for el in original_dict:
        if el['assistant'] != '':
            all_actions.append(get_assistant_action(el))
    return all_actions


if __name__ == '__main__':
    # vars = {"users": [{"link":"300300300","caption":"caption"}]}
    # html = get_template_fill(vars)
    # print(html)
    from raw_test_elements import values as raw_test_elements
    original_dict = to_original_dict(raw_test_elements)
    action_items = to_action_items(original_dict)
    print(action_items)
