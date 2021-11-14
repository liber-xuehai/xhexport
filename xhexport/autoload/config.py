from os import path, listdir


def get_rootdir() -> str:
    return path.abspath(path.join(path.dirname(__file__), '../../xuehai'))


def get_userid(rootdir) -> int:
    packages = listdir(path.join(rootdir, '5017/databases'))
    for package in packages:
        current = listdir(path.join(rootdir, '5017/databases', package))
        if len(current):
            return int(current[0])


class Config:
    def __init__(self):
        self.rootdir = get_rootdir()
        self.userid = get_userid(self.rootdir)


config = Config()