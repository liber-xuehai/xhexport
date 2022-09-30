# -*- coding: UTF-8 -*-

import json
import sqlite3
from os import path
from colorama import Fore
from xhexport import fs, config
from xhexport.utils.log import logger
from xhexport.utils.sql import select
from xhexport.utils.func import combine_same_origin_items

name = '资料中心'
package_name = 'com.xh.datacenter'
