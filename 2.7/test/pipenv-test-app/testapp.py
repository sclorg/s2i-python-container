import requests


def application(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/plain')])
    assert requests.__version__ == '2.20.0'
    return [b"Hello from gunicorn WSGI application!"]
