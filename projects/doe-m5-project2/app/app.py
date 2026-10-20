#!/usr/bin/env python3
"""Small HTTP app for the DOE M5 multi-environment deployment project."""
from http.server import BaseHTTPRequestHandler, HTTPServer
import json, os

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        payload = {"status": "ok", "environment": os.getenv("APP_ENVIRONMENT", "local"), "version": os.getenv("APP_VERSION", "dev")}
        if self.path == "/health":
            self.send_response(200)
        elif self.path == "/":
            payload["message"] = "DOE Module 5 Project 2 sample application"
            self.send_response(200)
        else:
            self.send_response(404)
            payload = {"error": "not found"}
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(payload).encode())

if __name__ == "__main__":
    HTTPServer(("0.0.0.0", int(os.getenv("PORT", "8080"))), Handler).serve_forever()
