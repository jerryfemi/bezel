import http.server
import socketserver
import os

PORT = 8080
DIRECTORY = "build/web"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
        
    def end_headers(self):
        # These headers are REQUIRED by browsers to enable SharedArrayBuffer for FFmpeg
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

if not os.path.exists(DIRECTORY):
    print(f"Error: {DIRECTORY} does not exist. Please run 'flutter build web' first.")
    exit(1)

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving {DIRECTORY} at http://localhost:{PORT}")
    print("Press Ctrl+C to stop.")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
