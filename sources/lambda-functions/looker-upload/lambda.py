import boto3
import os
import lookerapi as looker

session = boto3.Session()
client = boto3.client("s3")
ssm = boto3.client("ssm")

LOOKER_BASE_URL = "https://marketinvoice.looker.com:19999/api/3.0/"
LOOKER_CLIENT_ID = ssm.get_parameter(Name="LOOKER_CLIENT_ID", WithDecryption=True)[
    "Parameter"
]["Value"]
LOOKER_CLIENT_SECRET = ssm.get_parameter(
    Name="LOOKER_CLIENT_SECRET", WithDecryption=True
)["Parameter"]["Value"]


def _get_look_from_looker(look_number):
    """ Return the result of executing the look """
    unauthenticated_client = looker.ApiClient(LOOKER_BASE_URL)
    unauthenticated_authApi = looker.ApiAuthApi(unauthenticated_client)
    token = unauthenticated_authApi.login(
        client_id=LOOKER_CLIENT_ID, client_secret=LOOKER_CLIENT_SECRET
    )
    client = looker.ApiClient(
        LOOKER_BASE_URL, "Authorization", "token " + token.access_token
    )
    lookApi = looker.LookApi(client)
    return lookApi.run_look(look_number, "csv")


def upload_look(look_number):
    """ Upload the look to the public S3 bucket """
    result = _get_look_from_looker(look_number)
    client.put_object(
        Bucket="dev-jwat",
        Key=f"looker-look-{look_number}.csv",
        Body=result,
        ACL="public-read",
    )


def handler(event, context):
    """ Main function """
    return upload_look(1234)
