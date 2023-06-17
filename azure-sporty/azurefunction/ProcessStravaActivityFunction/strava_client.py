# https://www.grace-dev.com/python-apis/strava-api/
import json
import os
import requests
import time


class StravaClient():
    def __init__(self, client_id, client_secret, token_path) -> None:
        self.client_id = client_id
        self.client_secret = client_secret
        self.token_path = token_path

    def does_token_exist(self, token_path):
        return os.path.exists(token_path)
    
    def write_token(self, strava_token):
        with open(self.token_path, 'w') as outfile:
            json.dump(strava_token, outfile)

    def read_token(self):
        with open(self.token_path, 'r') as token:
            data = json.load(token)
        return data

    def get_or_refresh_access_token(self):
        redirect_uri = 'http://localhost/'
        if not self.does_token_exist(self.token_path):
            request_url = f'http://www.strava.com/oauth/authorize?client_id={self.client_id}' \
                        f'&response_type=code&redirect_uri={redirect_uri}' \
                        f'&approval_prompt=force' \
                        f'&scope=profile:read_all,activity:read_all'


            print('Click here:', request_url)
            print('Please authorize the app and copy&paste below the generated code!')
            print('P.S: you can find the code in the URL')
            code = input('Insert the code from the url: ')
            token = self._request_token(self.client_id, self.client_secret, code)
            #Save json response as a variable
            strava_token = token.json()
            # Save tokens to file
            self.write_token(strava_token)


        data = self.read_token()

        if data['expires_at'] < time.time():
            print('Refreshing token!')
            new_token = self._refresh_token(self.client_id, self.client_secret, data['refresh_token'])
            strava_token = new_token.json()
            # Update the file
            self.write_token(strava_token)
            data = strava_token

        access_token = data['access_token']
        return access_token

    def _request_token(self, client_id, client_secret, code):
        response = requests.post(url='https://www.strava.com/oauth/token',
                                data={'client_id': client_id,
                                    'client_secret': client_secret,
                                    'code': code,
                                    'grant_type': 'authorization_code'})
        return response

    def _refresh_token(self, client_id, client_secret, refresh_token):

        response = requests.post(url='https://www.strava.com/api/v3/oauth/token',
                                data={'client_id': client_id,
                                    'client_secret': client_secret,
                                    'grant_type': 'refresh_token',
                                    'refresh_token': refresh_token})
        return response


    def get_last_activities(self):
        access_token = self.get_or_refresh_access_token()
        activities_url = f"https://www.strava.com/api/v3/athlete/activities?" \
                f"access_token={access_token}"
        response = requests.get(activities_url)
        return response.json()[:5]




if __name__ == '__main__':
    client_id = os.getenv('STRAVA_CLIENT_ID')
    client_secret = os.getenv('STRAVA_CLIENT_SECRET')
    token_path = 'strava_token.json'
    stravaTokenClient = StravaClient(client_id, client_secret, token_path)
    access_token = stravaTokenClient.get_or_refresh_access_token()
    athlete_url = f"https://www.strava.com/api/v3/athlete?" \
                f"access_token={access_token}"
    response = requests.get(athlete_url)
    athlete = response.json()



