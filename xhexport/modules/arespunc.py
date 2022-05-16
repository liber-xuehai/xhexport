# -*- coding: UTF-8 -*-

import json
import sqlite3
from xhexport import fs, config
from xhexport.utils.log import logger
from xhexport.utils.sql import select

name = '响应'
package_name = 'com.xh.arespunc'


def build():
    log = logger(package_name)
    general_session = {}
    general_message = []
    for user_id in config.user_id:
        db_path = fs.join(config.school_db_root, package_name, user_id, str(user_id) + '.db')
        if fs.access(db_path)['type'] == 'none':
            continue
        log('open database', db_path)
        db = sqlite3.connect(db_path)

        session = {
            **{int(i[0]): dict(
                   name=i[1],
                   type='SINGLE',
                   last_update=0,
               )
               for i in select(db, 'CONTACT')},
            **{int(i[0]): dict(
                   name=i[1],
                   type=i[3],
                   last_update=i[7],
               )
               for i in select(db, 'SESSION')},
        }

        message = [dict(
            id=i[0],
            type=i[5],
            sender=session[int(i[1])]['name'],
            sender_id=int(i[1]),
            receiver=session[int(user_id)]['name'],
            receiver_id=int(user_id),
            session=session[int(i[2])]['name'],
            session_id=int(i[2]),
            session_type=session[int(i[2])]['type'],
            content=i[6],
            created_time=i[7],
        ) for i in select(db, 'CHAT_MSG')]

        general_session.update(session)
        general_message.extend(message)

    general_message.sort(key=lambda x: x['created_time'], reverse=True)

    log('write to result json')
    fs.write(config.result_root, 'arespunc/session.json', content=json.dumps(general_session, ensure_ascii=False))
    fs.write(config.result_root, 'arespunc/message.json', content=json.dumps(general_message, ensure_ascii=False))
