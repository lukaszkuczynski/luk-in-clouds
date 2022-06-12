from jinja2 import Environment, FileSystemLoader, select_autoescape
import os
from datetime import datetime

from dataextractor import to_action_items, validate_action_items

env = Environment(
    loader=FileSystemLoader("./"),
    autoescape=select_autoescape()
)


def get_html_page(context):
    template = env.get_template("welcome.html")
    rendered = template.render(
        context)
    return rendered


if __name__ == '__main__':
    from raw_test_elements import values
    from dataextractor import to_original_dict
    original_rows = to_original_dict(values)
    action_items = to_action_items(original_rows)
    good_action = {
        "template_name": "student",
        'date': '2020-01-01',
        "mail_to": "good"
    }
    bad_action = {
        "template_name": "student",
        'date': '2020-01-01',
        "mail_to": ""
    }
    # validation_results = validate_action_items([good_action, bad_action])
    validation_results = validate_action_items([good_action])
    context = {
        "creation_time": datetime.now(),
        "original_rows": [],
        "action_items": [],
        "mailsender_function_url": "",
        "validation_result": validation_results
    }
    page = get_html_page(context)
    with open('temp.html', 'w') as fout:
        fout.write(page)
