# -*- coding: UTF-8 -*-

import json
import sqlite3
from os import path
from colorama import Fore
from xhexport import fs, config
from xhexport.utils.log import logger
from xhexport.utils.sql import select
# from xhexport.methods.export_ppt import export_per_page as save_ppt

name = '云课堂'
package_name = 'com.xh.smartclassstu'
log = logger(package_name)


class SmartClassExportError(Exception):
    pass


def build():
    general_task = {}
    general_resource = []
    for user_id in config.user_id:
        db_path = fs.join(config.general_db_root, package_name, user_id, 'ztkt_stu_v4.db')
        if fs.access(db_path)['type'] == 'none':
            continue
        log('open database', db_path)
        db = sqlite3.connect(db_path)

        task = {
            i[24]: dict(
                id=i[0],
                name=i[7],
                user_id=user_id,
                class_id=i[1],
                resource_id=i[24],
                # remote_url=(i[10] or '')[:-2],
                create_time=i[13],
            )
            for i in select(db, 'TaskDetail') if i[24]
        }

        resource = [dict(
            **task[i[0]],
            download_time=i[3],
            type=int(i[4]),
            remote_url=i[2][:-2],
            local_path=i[6],
        ) for i in select(db, 'resourceinfo') if i[0] in task]
        resource.sort(
            key=lambda x: x['download_time'],
            reverse=True,
        )

        local_prefix = f'xuehai/{config.school_id}/filebases/{package_name}/{user_id}/ztktv4_resource/'
        for e in resource:
            if e['type'] == 6:
                basename = path.basename(e['remote_url'])[:-3]
                e['local_path'] = local_prefix + basename + e['local_path']
            elif e['type'] == 8:
                e['local_path'] = local_prefix + path.basename(e['remote_url'])

        general_task.update(task)
        general_resource.extend(resource)

    fs.write(json.dumps(general_task, ensure_ascii=False), config.result_root, 'smartclassstu/task_detail.json')
    fs.write(json.dumps(general_resource, ensure_ascii=False), config.result_root, 'smartclassstu/resource.json')


def export_ppt(data):
    log = logger('云课堂')
    log(data)
    log('导出课程', Fore.MAGENTA + data['id'] + Fore.RESET, \
        '课件', Fore.MAGENTA + data['name'] + Fore.RESET)
    local_dir = data['remote_url'][:-2].split('/')[-1]
    real_path = fs.join(config.school_file_root, package_name, data['user_id'], 'ztktv4_resource', local_dir, data["local_path"])
    dist_path = fs.join(config.result_root, 'export', f'smartclass-{data["id"]}', f'{data["name"]}.pptx')
    fs.makedirs(path.dirname(dist_path))
    # save_ppt(real_path, dist_path)


def export(data):
    if data['type'] == 5:
        return export_ppt(data)
    else:
        raise SmartClassExportError('不支持的类型')