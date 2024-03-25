import http.server
import signal
import socketserver
import sys

PORT = 8080

def sigterm_handler(signum, frame):
    print("SIGTERM received, performing cleanup...")
    sys.exit(0)

signal.signal(signal.SIGTERM, sigterm_handler)

class SimpleHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b"Hello, World!")

with socketserver.TCPServer(('', PORT), SimpleHTTPRequestHandler) as httpd:
    print("serving at port", PORT)
    httpd.serve_forever()
