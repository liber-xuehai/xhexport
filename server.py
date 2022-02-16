from flask import Flask, send_from_directory

app = Flask(__name__)


@app.route('/data/<path:path>')
def get_data(path):
    return send_from_directory('data', path)


@app.route('/<path:path>')
def get_web(path):
    rsp =  send_from_directory('web', path)
    rsp.cache_control.max_age = 3000
    return rsp


@app.route('/')
def get_index():
    return send_from_directory('web', 'index.html')


app.run()
