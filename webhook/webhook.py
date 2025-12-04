from flask import Flask, request
import os

app = Flask(__name__)

@app.route("/webhook", methods=['POST'])
def webhook():
    data = request.json
    os.system("ansible-playbook /opt/playbooks/heal.yml")
    return "OK", 200

app.run(host="0.0.0.0", port=5001)

