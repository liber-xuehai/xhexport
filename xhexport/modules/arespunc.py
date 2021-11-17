import json
import sqlite3
from xhexport import config
from xhexport.utils import locate_db, write_result
from xhexport.utils.sql import select

name = '响应'
package_name = 'com.xh.arespunc'


def build():
    db_file = locate_db(f'{package_name}/{config.userid}/{config.userid}.db')
    db = sqlite3.connect(db_file)

    session = {
        **{
            int(i[0]): dict(
                name=i[1],
                type='SINGLE',
                last_update=0,
            )
            for i in select(db, 'CONTACT')
        },
        **{
            int(i[0]): dict(
                name=i[1],
                type=i[3],
                last_update=i[7],
            )
            for i in select(db, 'SESSION')
        },
    }

    message = [
        dict(
            id=i[0],
            type=i[5],
            sender=session[int(i[1])]['name'],
            sender_id=int(i[1]),
            session=session[int(i[2])]['name'],
            session_id=int(i[2]),
            session_type=session[int(i[2])]['type'],
            content=i[6],
            created_time=i[7],
        ) for i in select(db, 'CHAT_MSG')
    ]
    message.sort(
        key=lambda x: x['created_time'],
        reverse=True,
    )

    write_result('arespunc/session.json',
                 json.dumps(session, ensure_ascii=False))
    write_result('arespunc/message.json',
                 json.dumps(message, ensure_ascii=False))
