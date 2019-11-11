import os
import time

from gunicorn.app.base import BaseApplication
from six import iteritems

print('LOADING MODULE %s' % __file__)

def wsgi_handler(environ, start_response):
    print('HANDLE REQUEST %s' % time.time())
    start_response('200 OK', [('Content-Type','text/html')])
    return [b"Hello World from standalone WSGI application!"]

class StandaloneApplication(BaseApplication):
    def __init__(self, app, options=None):
        self.options = options or {}
        self.application = app
        super(StandaloneApplication, self).__init__()

    def load_config(self):
        config = dict([(key, value) for key, value in iteritems(self.options)
                       if key in self.cfg.settings and value is not None])
        for key, value in iteritems(config):
            self.cfg.set(key.lower(), value)

    def load(self):
        return self.application

if __name__ == '__main__':
    StandaloneApplication(wsgi_handler, {'bind': ':8080'}).run()
