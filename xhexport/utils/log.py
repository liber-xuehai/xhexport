import sys
from colorama import Fore, Style

_rs = Style.RESET_ALL


def logger(prefix):
    def log(*args):
        sys.stderr.write(_rs + Fore.CYAN + '[' + prefix + ']' + _rs + ' ' + \
                         ' '.join(map(str, args)) + '\n' + _rs)

    return log