# -*- coding: UTF-8 -*-

import json
import sqlite3
from os import path
from colorama import Fore
from xhexport import fs, config
from xhexport.utils.log import logger
from xhexport.utils.sql import select
from xhexport.utils.func import combine_same_origin_items

name = '云课堂'
package_name = 'com.xh.smartclassstu'


class SmartClassExportError(Exception):
    pass


def build():
    log = logger(package_name)
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

        local_prefix = f'xuehai/{config.school_id}/filebases/{package_name}/{user_id}/ztktv4_resource/'
        for e in resource:
            if e['type'] == 6:
                basename = path.basename(e['remote_url'])[:-3]
                e['local_path'] = local_prefix + basename + e['local_path']
            elif e['type'] == 8:
                e['local_path'] = local_prefix + path.basename(e['remote_url'])

        general_task.update(task)
        general_resource.extend(resource)

    general_resource.sort(key=lambda x: x['download_time'], reverse=True)
    general_resource = combine_same_origin_items(general_resource)

    log('write to result json')
    fs.write(config.result_root, 'smartclassstu/task_detail.json', content=json.dumps(general_task, ensure_ascii=False))
    fs.write(config.result_root, 'smartclassstu/resource.json', content=json.dumps(general_resource, ensure_ascii=False))


def export(data):
    from xhexport.methods.ppt_exporter import export_per_page as export_ppt
    log = logger(package_name + ' export')
    if data['type'] == 5:
        log('导出课程', Fore.MAGENTA + data['id'] + Fore.RESET, '课件', Fore.MAGENTA + data['name'] + Fore.RESET)
        local_dir = data['remote_url'][:-3].split('/')[-1]
        local_path = data["local_path"] if not data["local_path"].startswith('/') else data["local_path"][1:]
        real_path = fs.join(config.school_file_root, package_name, data['user_id'], 'ztktv4_resource', local_dir, local_path)
        dist_path = fs.join(config.result_root, 'export', f'smartclass-{data["id"]}', f'{data["name"]}.pptx')
        fs.makedirs(path.dirname(dist_path))
        print(real_path)
        export_ppt(real_path, dist_path)
    else:
        raise SmartClassExportError('不支持的类型')