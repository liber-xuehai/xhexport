import sys

COMMANDS = ['build', 'server', 'export']

if len(sys.argv) == 1:
    sys.argv.append('build')

if sys.argv[1] not in COMMANDS:
    raise Exception('No command named ' + sys.argv[0])

command = sys.argv[1]
sys.argv.pop(1)
if command == 'build':
    from xhexport.scripts import build
elif command == 'export':
    from xhexport.scripts import export
elif command == 'server':
    from xhexport.scripts import server
