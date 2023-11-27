import sys
import requests


def application(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/plain')])
    # Python 3.12 needed requests version bump
    if sys.version_info.major == 3 and sys.version_info.minor >= 12:
        assert requests.__version__ == '2.28.2'
    else:
        assert requests.__version__ == '2.20.0'
    return [b"Hello from gunicorn WSGI application!"]
