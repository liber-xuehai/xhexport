import sys
from colorama import Fore, Style

_RS = Style.RESET_ALL
FORE = {
    'blue': Fore.BLUE,
    'cyan': Fore.CYAN,
    'green': Fore.GREEN,
    'magenta': Fore.MAGENTA,
    'red': Fore.RED,
    'yellow': Fore.YELLOW,
    'lightblue': Fore.LIGHTBLUE_EX,
    'lightcyan': Fore.LIGHTCYAN_EX,
    'lightgreen': Fore.LIGHTGREEN_EX,
    'lightmagenta': Fore.LIGHTMAGENTA_EX,
    'lightred': Fore.LIGHTRED_EX,
    'lightyellow': Fore.LIGHTYELLOW_EX,
}


def logger(prefix, color='cyan'):

    def log(*args):
        sys.stderr.write(_RS + FORE[color] + '[' + prefix + ']' + _RS + ' ' + ' '.join(map(str, args)) + '\n' + _RS)

    if color not in FORE:
        raise Exception('[logger] Selected color is not supported!')
    return log