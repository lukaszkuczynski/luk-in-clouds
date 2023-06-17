import logging
import json
import azure.functions as func
from strava_client import StravaTokenClient
import os

def main(req: func.HttpRequest, tokenIn: bytes, tokenOut: func.Out[bytes]) -> str:

    class AzureFunctionStravaTokenClient(StravaTokenClient):
        def __init__(self, client_id, client_secret) -> None:
            super().__init__(client_id, client_secret, '')

        def does_token_exist(self):
            return True
        
        def write_token(self, strava_token):
            tokenOut.set(json.dumps(strava_token))

        def get_token(self):
            return json.loads(tokenIn)

    client_id = os.getenv('STRAVA_CLIENT_ID')
    client_secret = os.getenv('STRAVA_CLIENT_SECRET')
    tokenClient = AzureFunctionStravaTokenClient(client_id, client_secret)
    logging.info('Python HTTP trigger function processed a request.')
    token_read = json.loads(tokenIn)
    logging.info(f"Read token {token_read}")
    tokenOut.set(json.dumps(token_read))
    logging.info(f"Token saved!")
    return func.HttpResponse(f"This Strava func executed successfully.")