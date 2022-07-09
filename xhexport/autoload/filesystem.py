import os
import requests
from os import path, listdir
from xhexport import config
from xhexport.utils.log import logger
from xhexport.utils.file import is_remote_url, join_path, relative_to

NOT_SUPPORTED = {'error': 'not supported!'}

log = logger('filesystem','lightblue')


def fetch_remote(url, data):
    log(url,data)
    rsp = requests.post(url, data=data)
    return rsp.content


class FileSystem:

    def join(self, *args):
        return join_path([*args])

    def access(self, *args):
        p = self.join(*args)
        if is_remote_url(p):
            return fetch_remote(self.join(config.source_root, '/api/access'), {
                'path': relative_to(config.source_root, p),
            })
        else:
            if not path.exists(p):
                return {
                    'type': 'none',
                }
            elif path.isdir(p):
                return {
                    'type': 'dir',
                    'list': listdir(p),
                }
            else:
                return {
                    'type': 'file',
                }

    def read(self, *args, **kwargs):
        p = self.join(*args)
        if is_remote_url(p):
            return fetch_remote(self.join(config.source_root, '/api/read'), {
                'path': relative_to(config.source_root, p),
                'encoding': kwargs.get('encoding', 'utf-8'),
            })
        else:
            self.makedirs(path.dirname(p))
            with open(p, 'r+', encoding=kwargs.get('encoding', 'utf-8')) as file:
                content = file.read()
            return content

    def write(self, *args, **kwargs):
        p = self.join(*args)
        if is_remote_url(p):
            return fetch_remote(self.join(config.source_root, '/api/write'), {
                'path': relative_to(config.source_root, p),
                'content': kwargs.get('content', ''),
                'encoding': kwargs.get('encoding', 'utf-8'),
            })
        else:
            self.makedirs(path.dirname(p))
            with open(p, 'w+', encoding=kwargs.get('encoding', 'utf-8')) as file:
                file.write(kwargs.get('content', ''))

    def makedirs(self, *args):
        p = self.join(*args)
        if is_remote_url(p):
            return NOT_SUPPORTED
        else:
            try:
                return os.makedirs(p)
            except FileExistsError:
                return None

    def __init__(self):
        pass


fs = FileSystem()