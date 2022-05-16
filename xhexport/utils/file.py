from os import path

PROJECT_ROOT = path.join(path.dirname(__file__), '../..')
CONFIG_PATH = path.join(PROJECT_ROOT, './config.yml')


def is_remote_url(p):
    if p.startswith('https://') or p.startswith('http://') or p.startswith('ftp://'):
        return True
    else:
        return False


def join_path(args):
    if is_remote_url(args[0]):
        return None  # !!TODO!!
    else:
        return path.abspath(path.join(*map(str, args)))


def parse_path(p):
    if is_remote_url(p):
        return p
    else:
        return path.abspath(path.join(PROJECT_ROOT, p))