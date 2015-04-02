
def application(environ, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return [b"Hello World from gunicorn WSGI application!"]
