#!/usr/bin/python3

import boto3
import os
import requests

class Targets:

    def __init__(self):
        pass

    def get(self):
        pass

    def unhealthy(self):
        pass

    def set_unhealthy(self, target):
        pass

    def assign_to_fix(self, name, target):
        pass


class Notifier:

    def __init__(self, token):
        self.token = token

    def notify(self, targets):
        pass

def getToken():
    client = boto3.client('ssm')
    name = os.environ("TOKEN_PATH")
    token = client.get_parameter('', true)
    return token['Value']

def check(event, context):
    global notifier
    token = getToken()
    notifier = Notifier(token)

    return {
            'message': 'success'
    }
