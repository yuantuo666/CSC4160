import requests
import json

# Local and remote URLs
url_local = 'http://localhost:8080/2015-03-31/functions/function/invocations'
url_lambda = "https://lavu1dhf1e.execute-api.us-east-1.amazonaws.com/default/iris_cal"

# Input data wrapped in a "body" field for Lambda
data1 = {"values": [[0.1, 2, 0.1, 3]]}
data2 = {"values": [[5.9, 3.0, 5.1, 2.3]]}

# Prepare the payload to match the Lambda's expectation (event body)
payload1 = {"body": json.dumps(data1)}
payload2 = {"body": json.dumps(data2)}

# Send the requests
result1 = requests.post(url_local, json=payload1).json()
result2 = requests.post(url_local, json=payload2).json()

# Print the results
print(result1, result2)
