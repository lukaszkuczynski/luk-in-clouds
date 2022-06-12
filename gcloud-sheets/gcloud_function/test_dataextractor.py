from unittest import TestCase, main
from unittest import TestCase, main
from dataextractor import validate_action_items


class DataExtractorTest(TestCase):

    def test_valid_is_good(self):
        action = {
            "template_name": "student",
            'date': '2020-01-01',
            "mail_to": "good"
        }
        validation_results = validate_action_items([action])
        assert validation_results[0] == True

    def test_invalid_is_not_good(self):
        action = {
            "template_name": "student",
            'date': '2020-01-01',
            "mail_to": ""
        }
        validation_results = validate_action_items([action])
        print(validation_results)
        assert validation_results[0] == False


if __name__ == '__main__':
    main()
