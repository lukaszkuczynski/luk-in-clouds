# [START storage_generate_signed_post_policy_v4]
import datetime
# [END storage_generate_signed_post_policy_v4]
import sys
# [START storage_generate_signed_post_policy_v4]
import os
from google.cloud import storage
import google


def generate_signed_post_policy_v4(bucket_name, blob_name):
    """Generates a v4 POST Policy and prints an HTML form."""
    # bucket_name = 'your-bucket-name'
    # blob_name = 'your-object-name'
    credentials, project = google.auth.default()
    storage_client = storage.Client(project, credentials)

    policy = storage_client.generate_signed_post_policy_v4(
        bucket_name,
        blob_name,
        expiration=datetime.timedelta(minutes=10),
        fields={
          'x-goog-meta-test': 'data'
        }
    )

    # Create an HTML form with the provided policy
    header = "<form action='{}' method='POST' enctype='multipart/form-data'>\n"
    form = header.format(policy["url"])

    # Include all fields returned in the HTML form as they're required
    for key, value in policy["fields"].items():
        form += f"  <input name='{key}' value='{value}' type='hidden'/>\n"

    form += "  <input type='file' name='file'/><br />\n"
    form += "  <input type='submit' value='Upload File' /><br />\n"
    form += "</form>"

    print(form)

    return form



def entrypoint(request):
    if request.method == 'OPTIONS':
        # Allows GET requests from any origin with the Content-Type
        # header and caches preflight response for an 3600s
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }

        return ('', 204, headers)

    bucket_name = os.getenv("BUCKET_NAME")
    filename = "a.jpg"
    response = generate_signed_post_policy_v4(bucket_name=bucket_name, blob_name=filename)

    # Set CORS headers for the main request
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
    }


    return (response, 200, headers)
