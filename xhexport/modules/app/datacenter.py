# -*- coding: UTF-8 -*-

import json
from os import path
from xhexport import fs, config
from xhexport.utils.log import logger
from xhexport.modules.database import Database
from xhexport.utils.func import combine_same_origin_items

name = '资料中心'
package_name = 'com.xh.datacenter'


class DataCenterExportError(Exception):
    pass


def build():
    log = logger(package_name)
    general_resource = []

    for user_id in config.user_id:
        db_path = fs.join(config.school_db_root, package_name, user_id, 'data.db')
        if fs.access(db_path)['type'] == 'none':
            continue
        db = Database(db_path)

        resource = []

        for row in db.selectKV('RESOURCE_LOCAL_ENTITY'):
            resource.append({
                'id': row['id'],
                'user_id': user_id,
                'download_time': row['down_time'],
                'create_time': row['create_time'],
                'update_time': row['update_time'],
                'type': row['resource_type'],
                'remote_url': row['file_url'][:-2],
            })
            file_basename = path.splitext(path.basename(row['file_url']))[0]
            zip_basename = path.splitext(path.basename(row['zip_url']))[0] if row['zip_url'] else None
            folder = row['save_cache_dir'][row['save_cache_dir'].index('xuehai'):]
            # print(row)
            if row['resource_type'] == 8:
                resource[-1]['local_path'] = f'{folder}/{file_basename}/pdf'
            elif row['resource_type'] == 6:
                pdf_folder = f'{folder}/{zip_basename}/pdf'
                target_folder = fs.join(config.school_file_root, pdf_folder[pdf_folder.index(package_name + '/preview'):])
                subfolder = fs.access(target_folder)['list'][0]
                resource[-1]['local_path'] = f'{pdf_folder}/{subfolder}/{subfolder}.pdf'

        general_resource.extend(resource)

    general_resource.sort(key=lambda x: x['download_time'], reverse=True)
    general_resource = combine_same_origin_items(general_resource)

    log('write to result json')
    fs.write(config.result_root, 'datacenter/resource.json', content=json.dumps(general_resource, ensure_ascii=False))
