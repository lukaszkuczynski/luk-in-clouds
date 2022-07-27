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
    def do_send(self, mailto, topic, content):
        print(f"Sending to {mailto} with topic {topic}")
        pass

    def send_all(self, schedule_items):
        responses = []
        for item in schedule_items:
            rendered = self.printer.print(item['template_name'], item)
            responses.append(self.do_send(
                item['mail_to'], item['topic'], rendered))
        return {val: key for (key, val) in responses}


class ConsoleOutSender(ScheduleSender):

    def do_send(self, mailto, topic, content):
        super().do_send(mailto, topic, content)
        print(content)
        return (True, mailto)


class SendgridSender(ScheduleSender):

    def __init__(self, from_email, sg_api_key, reply_to_email=None, reply_to_name=None) -> None:
        import sendgrid
        self.sendgrid_client = sendgrid.SendGridAPIClient(sg_api_key)
        self.from_email = from_email
        self.reply_to_email = reply_to_email or from_email
        self.reply_to_name = reply_to_name or from_email
        super().__init__()

    def do_send(self, mailto, topic, content):
        recipient = mailto
        super().do_send(mailto, topic, content)
        data = {
            "from": {
                "email": self.from_email,
                "name": self.from_email
            },
            "reply_to": {
                "email": self.reply_to_email,
                "name": self.reply_to_name
            },
            "content": [
                {
                    "type": "text/html",
                    "value": content
                }
            ],
            "personalizations": [
                {
                    "to": [
                        {
                            "email": recipient,
                            "name": recipient
                        }
                    ],
                    "subject": topic
                }
            ]
        }
        response = self.sendgrid_client.client.mail.send.post(
            request_body=data)
        if response.status_code == 202:
            return (True, recipient)
        else:
            print("error while sending with SendGrid,", response.status_code)
            return (False, recipient)


if __name__ == '__main__':
    from test_actions import test_actions
    sender = ConsoleOutSender('luk@wp.pl')
    print(sender.send_all(test_actions))
