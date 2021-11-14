from os import path
from xhexport import config

rootdir = config.rootdir


def locate(abspath):
    return path.abspath(path.join(rootdir, abspath))


def locate_db(abspath):
    return locate(path.join('./5017/databases', abspath))


def locate_file(abspath):
    return locate(path.join('./5017/filebases', abspath))
