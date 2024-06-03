import random
import json
import sys

def lambda_handler(event, context):
    RandomNum1 = random.randint(1, 10)
    RandomNum2 = random.randint(1, 50)

    total = RandomNum1 + RandomNum2

    # Business logic - if the total is even (no error and print total) or odd (an error and print errorMessage)
    if total % 2 == 0:
        result = {"total": total}
    else:
        result = {"errorMessage": "unknown result"}

    result_json = json.dumps(result)

    # Write only the JSON formated result to cloudwatch so we can easily search for it   
    sys.stdout.write(result_json + '\n')

    return total