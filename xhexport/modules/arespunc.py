from xhexport import config
from xhexport.utils import locate_db

name = '响应'
package_name = 'com.xh.arespunc'


def build():
    locate_db(f'{package_name}/{config.userid}/{config.userid}.db')
