from flask import Flask, abort, send_from_directory

app = Flask(__name__)


@app.route('/data/<path:path>')
def get_data(path):
    return send_from_directory('data', path)

@app.route('/xuehai/<path:path>')
def get_xuehai(path):
    return send_from_directory('xuehai', path)

@app.route('/<path:path>')
def get_web(path):
    if not path.startswith('frontend/'):
        abort(404)
    print(path[9:])
    rsp = send_from_directory('frontend', path[9:])
    rsp.cache_control.max_age = 3000
    return rsp

@app.route('/')
@app.route('/index.html')
def get_index():
    return send_from_directory('.', 'index.html')


app.run()
