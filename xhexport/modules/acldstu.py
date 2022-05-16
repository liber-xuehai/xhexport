# -*- coding: UTF-8 -*-

import json
import sqlite3
from xhexport import config
from xhexport.utils.sql import select

name = '云作业'
package_name = 'com.xh.acldstu'


def build():
    db_file = locate_db(f'{package_name}/{config.userid}/xh_yunzuoye.db')
    db = sqlite3.connect(db_file)

    dictionary = {}
    for col in select(db, 'Dictionary_v1'):
        if col[3] not in dictionary:
            dictionary[col[3]] = {}
        dictionary[col[3]][col[2]] = col[4]
    subject_dict = {int(i[0]): i[2] for i in select(db, 'SubjectInfo_v1')}

    download_bean = {i[0]: i[1] for i in select(db, 'DOWNLOAD_FILE_BEAN') if i[2] == 2}
    if download_bean != {}:
        path_start = list(download_bean.values())[0].index('com.xh.acldstu')
        path_start -= len('xuehai/5017/filebases/')
    else:
        path_start = 0

    homework = [dict(
        id=i[1],
        name=i[4],
        score=i[17],
        teacher_id=i[24],
        subject=subject_dict[i[9]] if i[9] in subject_dict else '',
        subject_id=i[9],
        create_time=i[3],
        update_time=i[10],
        remote_url=i[2],
        local_path=download_bean[i[2]][path_start:] if i[2] in download_bean else '',
    ) for i in select(db, 'xh_yzy_student_work_list')]
    homework.sort(
        key=lambda x: x['create_time'],
        reverse=True,
    )

    write_result(
        'acldstu/dictionary.json',
        json.dumps(dictionary, ensure_ascii=False),
    )
    write_result(
        'acldstu/homework.json',
        json.dumps(homework, ensure_ascii=False),
    )
