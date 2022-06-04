from jinja2 import Environment, FileSystemLoader, select_autoescape
import os
from datetime import datetime

from dataextractor import to_action_items

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
    context = {
        "creation_time": datetime.now(),
        "original_rows": original_rows,
        "action_items": action_items
    }
    page = get_html_page(context)
    with open('temp.html', 'w') as fout:
        fout.write(page)
