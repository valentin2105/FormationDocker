#!/usr/bin/env python
from flask import Flask, request, jsonify
from pprint import pprint
import json

app = Flask(__name__)

@app.route('/', methods=['GET'])
def main():
    hello_text = "Hello Formation Docker !!! v2"
    return jsonify(hello_text)
     
app.run(host='0.0.0.0', port=80, debug=True)
