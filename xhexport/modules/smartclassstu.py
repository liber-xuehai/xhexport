import json
import sqlite3
from xhexport import config
from xhexport.utils import locate, write_result
from xhexport.utils.sql import select_all

name = '云课堂'
package_name = 'com.xh.smartclassstu'


def build():
    db_file = locate(f'0/databases/{package_name}/' +
                     f'{config.userid}/ztkt_stu_v4.db')
    db = sqlite3.connect(db_file)

    task_rows = select_all(db, 'TaskDetail')
    task = {
        i[24]: dict(
            id=i[0],
            name=i[7],
            class_id=i[1],
            resource_id=i[24],
            # remote_url=(i[10] or '')[:-2],
            create_time=i[13],
        )
        for i in task_rows if i[24]
    }

    resource_rows = select_all(db, 'resourceinfo')
    resource = [
        dict(
            **task[i[0]],
            download_time=i[3],
            remote_url=i[2][:-2],
            type=int(i[4]),
            local_path=i[5],
        ) for i in resource_rows
    ]
    resource.sort(
        key=lambda x: x['download_time'],
        reverse=True,
    )

    write_result('smartclassstu/task_detail.json',
                 json.dumps(task, ensure_ascii=False))
    write_result('smartclassstu/resource.json',
                 json.dumps(resource, ensure_ascii=False))
