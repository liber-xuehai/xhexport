__all__ = ['config', 'fs']

from .autoload.filesystem import fs
from .autoload.config import config


def get_user_id():
    packages = fs.access(config.school_db_root)['list']
    user_id = []
    for package in packages:
        for user_str in fs.access(config.school_db_root, package)['list']:
            user = int(user_str)
            if user not in user_id:
                user_id.append(user)
    return user_id


config.user_id = get_user_id()