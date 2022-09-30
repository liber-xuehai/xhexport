import sqlite3
from typing import List, Dict
from xhexport import fs
from xhexport.utils.log import logger


class Database:

    def execute(self, command: str):
        cur = self.conn.cursor()
        cur.execute(command)
        return cur

    def select(self, table: str, filter: None or str = None) -> List[List]:
        cmd = 'SELECT * FROM ' + table
        if filter is not None:
            cmd += ' WHERE ' + filter
        return self.execute(cmd).fetchall()

    def selectKV(self, table: str, filter: None or str = None) -> List[Dict]:
        schema = self.execute(f"SELECT sql FROM sqlite_master WHERE type='table' and name='{table}';").fetchone()[0]
        cols = [row[1:].split(' ', 2)[0][:-1].lower() for row in schema[schema.index('(') + 1:-1].split(',')]
        return [{cols[i]: line[i] for i in range(len(line))} for line in self.select(table, filter)]

    def __init__(self, link: str):
        if link.startswith('http://') or link.startswith('https://') or link.startswith('ftp://'):
            # 如果这个数据库在云端，则应先缓存到本地再读取（功能未实现）
            raise Exception('Not supported.')
        else:
            path = link

        logger('database')('open', path)
        self.conn = sqlite3.connect(path)