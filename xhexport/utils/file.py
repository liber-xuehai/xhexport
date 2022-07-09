from os import path
from urllib.parse import urljoin

PROJECT_ROOT = path.join(path.dirname(__file__), '../..')
CONFIG_PATH = path.join(PROJECT_ROOT, './config.yml')


def is_remote_url(p):
    if p.startswith('https://') or p.startswith('http://') or p.startswith('ftp://'):
        return True
    else:
        return False


def join_path(args):
    if is_remote_url(args[0]):
        base = args[0]
        for i in range(1, len(args)):
            base = urljoin(base, str(args[i]))
        return base
    else:
        return path.abspath(path.join(*map(str, args)))


def parse_path(p):
    if is_remote_url(p):
        if not p.endswith('/'):
            p += '/'
        return p
    else:
        return path.abspath(path.join(PROJECT_ROOT, p))


def relative_to(source, dist):
    if source.endswith('/'):
        source = source[:-1]
    if dist.endswith('/'):
        dist = dist[:-1]
    if dist.startswith(source):
        return dist[len(source):]
    else:
        return source  # TODO
