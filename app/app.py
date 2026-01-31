from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route('/')

def hello_gcc():
    html = "<h3>Hello GCC!</h3>" \
           "<b>Environment:</b> {env}<br/>" \
           "<b>Hostname:</b> {hostname}<br/>"
    return html.format(env=os.getenv("ENVIRONMENT", "dev"), 
                       hostname=socket.gethostname())

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
           