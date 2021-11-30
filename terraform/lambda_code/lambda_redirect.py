# This is the Lambda code that will be deployed to AWS
import json
from urllib import parse


def lambda_handler(event, context):
    # Get the site we want to redirect to from the "proxy" part of the submitted URL (from API Gateway). Use urllib to escape URL-unfriendly characters
    redirect_site = parse.quote(event["pathParameters"]["proxy"])

    # Build our response object as a Python dict object
    response = dict()
    response["statusCode"] = 302
    response["body"] = json.dumps(dict())
    response["headers"] = {"Location": f"https://www.{redirect_site}.com"}

    return response

