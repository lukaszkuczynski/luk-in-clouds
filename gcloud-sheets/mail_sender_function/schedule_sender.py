from abc import abstractmethod
from jinja2 import Environment, FileSystemLoader, select_autoescape


env = Environment(
    loader=FileSystemLoader("./"),
    autoescape=select_autoescape()
)


class MailPrinter():

    def print(self, template_name, context):
        template = env.get_template(f"templates/{template_name}.html")
        rendered = template.render(
            context)
        return rendered


class ScheduleSender():

    def __init__(self) -> None:
        self.printer = MailPrinter()

    @abstractmethod
    def do_send(self, item):
        pass

    def send_all(self, schedule_items):
        for item in schedule_items:
            print(f"Going to send item for {item['item']}")
            rendered = self.printer.print(item['template_name'], item)
            self.do_send(rendered)


class ConsoleOutSender(ScheduleSender):

    def do_send(self, item):
        print(item)
        return super().do_send(item)


if __name__ == '__main__':
    from test_actions import test_actions
    sender = ConsoleOutSender()
    sender.send_all(test_actions)
