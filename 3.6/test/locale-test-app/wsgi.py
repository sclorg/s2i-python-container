import locale
import os
import sys

from flask import Flask
application = Flask(__name__)

@application.route('/')
def hello():
    assert os.environ['PYTHONIOENCODING'] == 'UTF-8'
    assert os.environ['LC_ALL'] == 'en_US.UTF-8'
    assert os.environ['LANG'] == 'en_US.UTF-8'

    assert locale.getdefaultlocale() == ('en_US', 'UTF-8')
    assert locale.getpreferredencoding() == 'UTF-8'

    print(u'\u292e')

    return b'Hello World from locale test application!'

print('-- GLOBAL --')

for k,v in os.environ.items():
    print('%r=%r' % (k, v))

print()

print(sys.stdout.encoding)
print(locale.getlocale())
print(locale.getdefaultlocale())
print(locale.getpreferredencoding())

try:
    print(u'\u292e')
except Exception as e:
    print(e)

print('------------')

if __name__ == '__main__':
    application.run()
