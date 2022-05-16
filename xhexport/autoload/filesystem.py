import os
from os import path, listdir
from xhexport.utils.file import is_remote_url, join_path

NOT_SUPPORTED = {'error': 'not supported!'}


class FileSystem:

    def join(self, *args):
        return join_path([*args])

    def access(self, *args):
        p = self.join(*args)
        if is_remote_url(p):
            return NOT_SUPPORTED
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

    def write(self, content, *args):
        p = self.join(*args)
        if is_remote_url(p):
            return NOT_SUPPORTED
        else:
            self.makedirs(path.dirname(p))
            with open(p, 'w+', encoding='utf-8') as file:
                file.write(content)

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