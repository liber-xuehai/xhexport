# -*- coding: UTF-8 -*-

import json
import sqlite3
from os import path
from colorama import Fore
from xhexport import config
from xhexport.utils import locate, write_result, logger, makedirs
from xhexport.utils.sql import select
from xhexport.methods.export_ppt import export_per_page as save_ppt

name = '云课堂'
package_name = 'com.xh.smartclassstu'


class SmartClassExportError(Exception):
    pass


def build():
    db_file = locate(f'0/databases/{package_name}/' +
                     f'{config.userid}/ztkt_stu_v4.db')
    db = sqlite3.connect(db_file)

    task = {
        i[24]: dict(
            id=i[0],
            name=i[7],
            class_id=i[1],
            resource_id=i[24],
            # remote_url=(i[10] or '')[:-2],
            create_time=i[13],
        )
        for i in select(db, 'TaskDetail') if i[24]
    }

    resource = [
        dict(
            **task[i[0]],
            download_time=i[3],
            remote_url=i[2][:-2],
            type=int(i[4]),
            local_path=i[6],
        ) for i in select(db, 'resourceinfo') if i[0] in task
    ]
    resource.sort(
        key=lambda x: x['download_time'],
        reverse=True,
    )

    write_result('smartclassstu/task_detail.json',
                 json.dumps(task, ensure_ascii=False))
    write_result('smartclassstu/resource.json',
                 json.dumps(resource, ensure_ascii=False))


def export_ppt(data):
    log = logger('云课堂')
    log(data)
    log('导出课程', Fore.MAGENTA + data['id'] + Fore.RESET, \
        '课件', Fore.MAGENTA + data['name'] + Fore.RESET)
    local_dir = data['remote_url'][:-2].split('/')[-1]
    real_path = locate(f'5017/filebases/{package_name}/{config.userid}/' +
                       f'ztktv4_resource/{local_dir}/{data["local_path"]}')
    dist_path = path.join(config.distdir, 'export', f'smartclass-{data["id"]}',
                          f'{data["name"]}.pptx')
    makedirs(path.dirname(dist_path))
    save_ppt(real_path, dist_path)


def export(data):
    if data['type'] == 5:
        return export_ppt(data)
    else:
        raise SmartClassExportError('不支持的类型')