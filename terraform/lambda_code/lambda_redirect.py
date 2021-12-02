# This is the Lambda code that will be deployed to AWS
import json
from urllib import parse


def lambda_handler(event, context):
    print(f"Event submitted to the Lambda: {event}")

    # Get the site we want to redirect to from the "proxy" part of the submitted URL (from API Gateway). Use urllib to escape URL-unfriendly characters
    redirect_site = parse.quote(event["pathParameters"]["proxy"])

    print(f"Site submitted by user to redirect to: {redirect_site}")

    # Build our response object as a Python dict object
    response = dict()
    response["statusCode"] = 302
    response["body"] = json.dumps(dict())
    response["headers"] = {"Location": f"https://www.{redirect_site}.com"}

    print(f"Response being returned to API Gateway, then to the user: {response}")

    return response

