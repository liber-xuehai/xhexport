# -*- coding: UTF-8 -*-

import sys
import json
from base64 import b64decode
from xhexport.modules.app import smartclassstu

if len(sys.argv) != 3:
    print('参数错误')
    sys.exit(-1)

type = sys.argv[1]

base64 = sys.argv[2]
plain = b64decode(base64).decode('utf-8')
data = json.loads(plain)

if type == 'smartclassstu' or type == 'smartclass' or type == 'ykt' or type == '云课堂':
    smartclassstu.export(data)
else:
    print('不合法的导出类型')
    sys.exit(-1)