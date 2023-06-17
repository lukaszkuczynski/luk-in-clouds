import logging
import json
import azure.functions as func


def main(req: func.HttpRequest, tokenIn: bytes, tokenOut: func.Out[bytes]) -> str:
    logging.info('Python HTTP trigger function processed a request.')
    token_read = json.loads(tokenIn)
    logging.info(f"Read token {token_read}")
    tokenOut.set(json.dumps(token_read))
    logging.info(f"Token saved!")
    return func.HttpResponse(f"This Strava func executed successfully.")