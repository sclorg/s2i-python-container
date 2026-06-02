import os
try:
    import mod_wsgi.express.cli as server_wrapper
except ImportError:
  import mod_wsgi.server as server_wrapper

server_wrapper.start(
  '--log-to-terminal',
  '--port', '8080',
  '--trust-proxy-header', 'X-Forwarded-For',
  '--trust-proxy-header', 'X-Forwarded-Port',
  '--trust-proxy-header', 'X-Forwarded-Proto',
  '--processes', os.environ.get('MOD_WSGI_PROCESSES', '1'),
  '--threads', os.environ.get('MOD_WSGI_THREADS', '5'),
  '--application-type', 'module',
  '--entry-point', 'wsgi'
)
