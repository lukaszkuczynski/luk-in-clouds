# https://www.grace-dev.com/python-apis/strava-api/
import json
import os
import requests
import time



def get_access_token():
    client_id = os.getenv('STRAVA_CLIENT_ID')
    client_secret = os.getenv('STRAVA_CLIENT_SECRET')


    redirect_uri = 'http://localhost/'

    def request_token(client_id, client_secret, code):
        response = requests.post(url='https://www.strava.com/oauth/token',
                                data={'client_id': client_id,
                                    'client_secret': client_secret,
                                    'code': code,
                                    'grant_type': 'authorization_code'})
        return response

    def refresh_token(client_id, client_secret, refresh_token):

        response = requests.post(url='https://www.strava.com/api/v3/oauth/token',
                                data={'client_id': client_id,
                                    'client_secret': client_secret,
                                    'grant_type': 'refresh_token',
                                    'refresh_token': refresh_token})
        return response

    def write_token(token):

        with open('strava_token.json', 'w') as outfile:
            json.dump(token, outfile)


    def get_token():

        with open('strava_token.json', 'r') as token:
            data = json.load(token)

        return data

    if not os.path.exists('./strava_token.json'):
        request_url = f'http://www.strava.com/oauth/authorize?client_id={client_id}' \
                    f'&response_type=code&redirect_uri={redirect_uri}' \
                    f'&approval_prompt=force' \
                    f'&scope=profile:read_all,activity:read_all'


        print('Click here:', request_url)
        print('Please authorize the app and copy&paste below the generated code!')
        print('P.S: you can find the code in the URL')
        code = input('Insert the code from the url: ')

        token = request_token(client_id, client_secret, code)

        #Save json response as a variable
        strava_token = token.json()
        # Save tokens to file
        write_token(strava_token)


    data = get_token()

    if data['expires_at'] < time.time():
        print('Refreshing token!')
        new_token = refresh_token(client_id, client_secret, data['refresh_token'])
        strava_token = new_token.json()
        # Update the file
        write_token(strava_token)

    data = get_token()

    access_token = data['access_token']
    return access_token

if __name__ == '__main__':
    access_token = get_access_token()
    athlete_url = f"https://www.strava.com/api/v3/athlete?" \
                f"access_token={access_token}"
    response = requests.get(athlete_url)
    athlete = response.json()

    print('RESTful API:', athlete_url)
    print('='* 5, 'ATHLETE INFO', '=' * 5)
    print('Name:', athlete['firstname'], athlete['lastname'])
    print('Gender:', athlete['sex'])
    print('City:', athlete['city'], athlete['country'])
    print('Strava athlete from:', athlete['created_at'])

    activities_url = f"https://www.strava.com/api/v3/athlete/activities?" \
            f"access_token={access_token}"
    print('RESTful API:', activities_url)
    response = requests.get(activities_url)
    activity = response.json()[5]

    print('='*5, 'SINGLE ACTIVITY', '='*5)
    print('Athlete:', athlete['firstname'], athlete['lastname'])
    print('Name:', activity['name'])
    print('Date:', activity['start_date'])
    print('Disance:', activity['distance'], 'm')
    print('Average Speed:', activity['average_speed'], 'm/s')
    print('Max speed:', activity['max_speed'], 'm/s')
    print('Moving time:', round(activity['moving_time'] / 60, 2), 'minutes')
    print('Location:', activity['location_city'], 
        activity['location_state'], activity['location_country'])