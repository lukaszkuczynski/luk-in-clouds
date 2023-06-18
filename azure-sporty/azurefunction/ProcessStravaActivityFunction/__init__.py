import logging
import json
import azure.functions as func
from . import strava_client
import os

def main(req: func.HttpRequest, tokenIn: bytes, tokenOut: func.Out[bytes], resultFile: func.Out[bytes]) -> str:

    class AzureFunctionStravaClient(strava_client.StravaClient):
        def __init__(self, client_id, client_secret) -> None:
            super().__init__(client_id, client_secret, '')

        def does_token_exist(self, token_path):
            return True
        
        def write_token(self, strava_token):
            logging.info(f"going to write token..")
            tokenOut.set(json.dumps(strava_token))

        def read_token(self):
            logging.info(f"token reading {tokenIn}")
            return json.loads(tokenIn)

    client_id = os.getenv('STRAVA_CLIENT_ID')
    client_secret = os.getenv('STRAVA_CLIENT_SECRET')
    stravaClient = AzureFunctionStravaClient(client_id, client_secret)
    activities = stravaClient.get_last_activities()
    # token_read = json.loads(tokenIn)
    logging.info(f"Read activities {activities}")
    resultFile.set(json.dumps(activities))
    # logging.info(f"Token saved!")
    return func.HttpResponse(f"This Strava func executed successfully.")