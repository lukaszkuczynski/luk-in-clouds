import os

from event_reader import EventReader
from flask import (Flask, redirect, render_template, request,
                   send_from_directory, url_for)

app = Flask(__name__)

event_reader = EventReader()

@app.route('/')
def index():
   print('Request for index page received')
   events = event_reader.query_events()
   return render_template('index.html', events=events)

@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'),
                               'favicon.ico', mimetype='image/vnd.microsoft.icon')


if __name__ == '__main__':
   app.run(debug=True, port=5001)
