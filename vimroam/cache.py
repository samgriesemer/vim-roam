import os
import dill as pickle
from pathlib import Path
from datetime import datetime


class Cache():
    def __init__(self, name, path, default=None):
        self.name = name
        self.path = path
        self.default = default

        self.obj = None
        self.file = Path(path, name)
        self.file = self.file.with_suffix(self.file.suffix+'.pkl')
        self.rtime = -1

        Path(path).mkdir(parents=True, exist_ok=True)
        self.file.touch()

    def load(self):
        if self.rtime < self.file.stat().st_mtime:
            if self.file.stat().st_size == 0:
                if self.default is not None:
                    self.obj = self.default()
                    return self.obj
                else:
                    return None
            with self.file.open('rb') as f:
                self.obj = pickle.load(f)
            self.rtime = datetime.now().timestamp()
        return self.obj

    def write(self, obj=None):
        if obj is None: obj = self.obj
        with self.file.open('wb') as f:
            pickle.dump(obj, f)

