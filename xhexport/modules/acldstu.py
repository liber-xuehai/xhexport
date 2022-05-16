# -*- coding: UTF-8 -*-

import json
import sqlite3
from xhexport import fs, config
from xhexport.utils.log import logger
from xhexport.utils.sql import select

name = '云作业'
package_name = 'com.xh.acldstu'


def build():
    log = logger(package_name)
    dictionary = None
    general_homework = []
    for user_id in config.user_id:
        db_path = fs.join(config.school_db_root, package_name, user_id, 'xh_yunzuoye.db')
        if fs.access(db_path)['type'] == 'none':
            continue
        log('open database', db_path)
        db = sqlite3.connect(db_path)

        if dictionary is None:
            dictionary = {}
            for col in select(db, 'Dictionary_v1'):
                if col[3] not in dictionary:
                    dictionary[col[3]] = {}
                dictionary[col[3]][col[2]] = col[4]
            subject_dict = {int(i[0]): i[2] for i in select(db, 'SubjectInfo_v1')}

        download_bean = {i[0]: i[1] for i in select(db, 'DOWNLOAD_FILE_BEAN') if i[2] == 2}
        if download_bean != {}:
            path_start = list(download_bean.values())[0].index(package_name)
            path_start -= len(f'xuehai/{config.school_id}/filebases/')
        else:
            path_start = 0

        homework = [dict(
            id=i[1],
            name=i[4],
            score=i[17],
            user_id=user_id,
            teacher_id=i[24],
            subject=subject_dict[i[9]] if i[9] in subject_dict else '',
            subject_id=i[9],
            create_time=i[3],
            update_time=i[10],
            remote_url=i[2],
            local_path=download_bean[i[2]][path_start:] if i[2] in download_bean else '',
        ) for i in select(db, 'xh_yzy_student_work_list')]

        general_homework.extend(homework)

    general_homework.sort(key=lambda x: x['create_time'], reverse=True)

    log('write to result json')
    fs.write(config.result_root, 'acldstu/dictionary.json', content=json.dumps(dictionary, ensure_ascii=False))
    fs.write(config.result_root, 'acldstu/homework.json', content=json.dumps(general_homework, ensure_ascii=False))
