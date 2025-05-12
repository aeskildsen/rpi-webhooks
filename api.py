import os
import yaml
from flask import Flask, jsonify

app = Flask(__name__)

# Automate creation of route handlers based on yaml data
def create_route_handler(command, response_message):
    def route_handler():
        os.system(command)
        return response_message, 200
    return route_handler

# Load routes from YAML file
with open('/etc/opt/rpi-webhooks/routes.yaml', 'r') as file:
    routes_data = yaml.safe_load(file)

routes = routes_data['routes']

# Create the actual routes
for route, config in routes.items():
    command = config['command']
    response_message = config['response_message']
    app.add_url_rule(route, route[1:], create_route_handler(command, response_message), methods=['POST'])

# Global error handler for 405 Method Not Allowed
@app.errorhandler(405)
def method_not_allowed(e):
    return jsonify({'Error': 'Method not allowed. Please use POST requests only.'}), 405

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
