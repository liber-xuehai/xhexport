from os import path
from xhexport import config

rootdir = config.rootdir
distdir = config.distdir


def locate(abspath):
    return path.abspath(path.join(rootdir, abspath))


def locate_db(abspath):
    return locate(path.join('./5017/databases', abspath))


def locate_file(abspath):
    return locate(path.join('./5017/filebases', abspath))


def write_result(abspath, content):
    file = open(path.abspath(path.join(distdir, abspath)), 'w+',encoding='utf-8')
    file.write(content)
    file.close()
