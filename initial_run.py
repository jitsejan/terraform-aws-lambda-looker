""" initial_run.py """
import boto3

PREFIX = 'dev-'

lambda_client = boto3.client("lambda", "eu-west-2")

# Trigger the Lambda functions
for function in [
    fun["FunctionName"]
    for fun in lambda_client.list_functions()["Functions"]
    if fun["FunctionName"].startswith(PREFIX)
]:
    print("> Running function `%s`." % function)
    response = lambda_client.invoke(FunctionName=function)
    print("< Response: %s" % response)
