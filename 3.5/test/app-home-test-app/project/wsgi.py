# Import to test properly set PYTHONPATH
from lib import hello_world

def application(environ, start_response):
    start_response('200 OK', [('Content-Type','text/plain')])
    return hello_world()
