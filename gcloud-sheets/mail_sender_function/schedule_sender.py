from abc import abstractmethod


class MailPrinter():

    def print():
        pass


class ScheduleSender():

    @abstractmethod
    def do_send(schedule):
        pass

    def send_all(schedule_items):
        for item in schedule_items:
            print(f"Going to send item for {item['name']}")
            do_send(item)
