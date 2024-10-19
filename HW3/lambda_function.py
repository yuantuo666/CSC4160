import pickle
import json

# Load the model
filename = 'iris_model.sav'
model = pickle.load(open(filename, 'rb'))

def predict(features):
    return model.predict(features).tolist()

def lambda_handler(event, context):
    # TODO: Implement your own lambda_handler logic here
    # You will need to extract the 'values' from the event and call the predict function.
    
    try:
        body = json.loads(event['body'])
        values = body['values']
        result = predict(values)
        return { # must be in this format, or the test will fail: {"message": "Internal server error"}%
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
            },
            'body': json.dumps(result),
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
            },
            'body': json.dumps({'error': str(e)}),
        }
