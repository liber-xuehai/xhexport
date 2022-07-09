import yaml
from os import path
from xhexport.utils.file import is_remote_url, join_path, parse_path, CONFIG_PATH


class Config:

    @property
    def user_id(self):
        if self._user_id:
            return self._user_id
        
        from xhexport import fs
        print(self.school_db_root)
        print(fs.access(self.school_db_root))
        packages = fs.access(self.school_db_root)['list']
        self._user_id = []
        for package in packages:
            for user_str in fs.access(self.school_db_root, package)['list']:
                user = int(user_str)
                if user not in self._user_id:
                    self._user_id.append(user)
        return self._user_id

    def __init__(self):
        with open(CONFIG_PATH, 'r+', encoding='utf-8') as file:
            data = yaml.load(file.read(), Loader=yaml.SafeLoader)

        self._is_remote_url = is_remote_url
        self._join_path = join_path

        self.chrome = data.get('chrome', None)
        self.chrome_driver = data.get('chrome_driver', None)

        self.school_id = data.get('school_id')
        self._user_id = None  # real user_id would be calculated when call getter the first time

        self.source_root = parse_path(data.get('source_root'))
        self.result_root = parse_path(data.get('result_root'))

        self.general_db_root = join_path([self.source_root, '0', 'databases'])
        self.general_file_root = join_path([self.source_root, '0', 'filebases'])
        self.school_db_root = join_path([self.source_root, self.school_id, 'databases'])
        self.school_file_root = join_path([self.source_root, self.school_id, 'filebases'])


config = Config()