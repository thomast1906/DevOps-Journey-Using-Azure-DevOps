from azure.monitor.opentelemetry import configure_azure_monitor
from flask import Flask, render_template
import os

# Reads APPLICATIONINSIGHTS_CONNECTION_STRING env var automatically
configure_azure_monitor()

app = Flask(__name__)

@app.route('/')
def hello():
    return render_template('index.html')

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
