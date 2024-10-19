import logging
import time
from locust import HttpUser, task, between
import os


os.makedirs("locust_logs", exist_ok=True)

class LambdaTestUser(HttpUser):
    wait_time = between(3, 5)  # Time between requests for each user (3-5 seconds)
    # Payload for the POST request
    payload = {
        "values": [[5.9, 3.0, 5.1, 2.3]]
    }

    @task
    def lambda_request(self):
        start_time = time.time()  # Record the start time
        response = self.client.post("/default/iris_cal", json=self.payload)  # Send request to the Lambda
        end_time = time.time()  # Record the end time
        response_time_ms = 1000 * (end_time - start_time)  # Calculate the response time in milliseconds
        
        # Log the response time to observe the latency (which includes cold start time if applicable)
        logging.info(f"Response time: {response_time_ms:.2f} ms")
        # Optionally, you can log the status code and response for debugging purposes
        logging.info(f"Response status code: {response.status_code}")
        logging.info(f"Response text: {response.text}")
