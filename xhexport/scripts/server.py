from flask import Flask, request, abort, send_from_directory
from xhexport import fs, config
from xhexport.utils.file import is_remote_url

app = Flask(__name__)

FS_NOT_ACTIVED = {'error': 'Remote fs isn\'t actived.'} if is_remote_url(config.source_root) else None


@app.route('/fs/api/access', methods=['POST'])
def fs_access():
    if FS_NOT_ACTIVED:
        return FS_NOT_ACTIVED
    return fs.access(request.form['path'])


@app.route('/fs/api/read', methods=['POST'])
def fs_read():
    if FS_NOT_ACTIVED:
        return FS_NOT_ACTIVED
    return fs.read(
        request.form['path'],
        encoding=request.form['encoding'] or 'utf-8',
    )


@app.route('/fs/api/write', methods=['POST'])
def fs_write():
    if FS_NOT_ACTIVED:
        return FS_NOT_ACTIVED
    return fs.write(
        request.form['path'],
        content=request.form['content'],
        encoding=request.form['encoding'] or 'utf-8',
    )


@app.route('/fs/<path:path>')
def fs_default(path):
    if FS_NOT_ACTIVED:
        return FS_NOT_ACTIVED
    return send_from_directory(config.source_root, path)


@app.route('/data/<path:path>')
def get_data(path):
    return send_from_directory('../../data', path)


@app.route('/xuehai/<path:path>')
def get_xuehai(path):
    return send_from_directory(config.source_root, path)


@app.route('/<path:path>')
def get_web(path):
    if not path.startswith('frontend/'):
        abort(404)
    path = path[9:]
    rsp = send_from_directory('../../frontend', path)
    if path.startswith('thirdparty'):
        rsp.headers['Cache-Control'] = 'max-age=3000'
    return rsp


@app.route('/')
@app.route('/index.html')
def get_index():
    return send_from_directory('../..', 'index.html')


app.run(host="0.0.0.0")
