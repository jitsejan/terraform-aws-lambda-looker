# terraform-aws-lambda-looker
Simple Terraform deployment of a Lambda function that exports a Looker view to S3


## Terraform initialization

```bash
╭─    ~/code/terraform-aws-lambda-looker     master                                 1 ↵  22:09    90%   3.11G 
╰─ terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (2.10.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.10"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## Terraform plan

```bash
╭─    ~/code/terraform-aws-lambda-looker     master                            3.75   22:09    90%   3.09G 
╰─ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_cloudwatch_event_rule.cloudwatch-event-rule-midnight-run
      id:                             <computed>
      arn:                            <computed>
      description:                    "Cloudwatch event rule to run every day at midnight for the Looker upload."
      is_enabled:                     "true"
      name:                           "dev-cloudwatch-event-rule-midnight-run-looker-upload"
      schedule_expression:            "cron(0 0 * * ? *)"

  + aws_cloudwatch_event_target.cloudwatch-event-target
      id:                             <computed>
      arn:                            "arn:aws:lambda:eu-west-1:848373817713:function:dev-lambda-looker-upload"
      rule:                           "dev-cloudwatch-event-rule-midnight-run"
      target_id:                      <computed>

  + aws_iam_role.role-lambda
      id:                             <computed>
      arn:                            <computed>
      assume_role_policy:             "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}\n"
      create_date:                    <computed>
      description:                    "Role to execute all Lambda related tasks."
      force_detach_policies:          "false"
      max_session_duration:           "3600"
      name:                           "dev-jwat-role-lambda"
      path:                           "/"
      unique_id:                      <computed>

  + aws_iam_role_policy.policy-lambda
      id:                             <computed>
      name:                           "dev-jwat-policy-lambda"
      policy:                         "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"lambda:InvokeFunction\",\n        \"logs:CreateLogGroup\",\n        \"logs:CreateLogStream\",\n        \"logs:PutLogEvents\",\n        \"ssm:GetParameter\",\n        \"s3:PutObject\",\n        \"s3:ListBucket\",\n        \"s3:GetObject\"\n      ],\n      \"Resource\": [\n        \"*\"\n      ]\n    }\n  ]\n}\n"
      role:                           "${aws_iam_role.role-lambda.id}"

  + aws_lambda_function.lambda-function
      id:                             <computed>
      arn:                            <computed>
      description:                    "Lambda function for uploading a Looker view"
      filename:                       "sources/lambda-functions/looker-upload/lambda.zip"
      function_name:                  "dev-lambda-looker-upload"
      handler:                        "lambda.handler"
      invoke_arn:                     <computed>
      last_modified:                  <computed>
      memory_size:                    "128"
      publish:                        "false"
      qualified_arn:                  <computed>
      reserved_concurrent_executions: "-1"
      role:                           "${aws_iam_role.role-lambda.arn}"
      runtime:                        "python3.7"
      source_code_hash:               <computed>
      source_code_size:               <computed>
      tags.%:                         "2"
      tags.Environment:               "Development"
      tags.Owner:                     "Jitse-Jan"
      timeout:                        "3"
      tracing_config.#:               <computed>
      version:                        <computed>

  + aws_lambda_permission.lambda-permission-cloudwatch
      id:                             <computed>
      action:                         "lambda:InvokeFunction"
      function_name:                  "dev-lambda-looker-upload"
      principal:                      "events.amazonaws.com"
      source_arn:                     "arn:aws:events:eu-west-1:848373817713:rule/dev-cloudwatch-event-rule-midnight-run-looker-upload"
      statement_id:                   "AllowExecutionFromCloudWatch"

  + aws_s3_bucket.bucket-lambda-deployments
      id:                             <computed>
      acceleration_status:            <computed>
      acl:                            "public-read"
      arn:                            <computed>
      bucket:                         "dev-jwat"
      bucket_domain_name:             <computed>
      bucket_regional_domain_name:    <computed>
      force_destroy:                  "false"
      hosted_zone_id:                 <computed>
      region:                         "eu-west-2"
      request_payer:                  <computed>
      tags.%:                         "2"
      tags.Environment:               "Development"
      tags.Owner:                     "Jitse-Jan"
      versioning.#:                   "1"
      versioning.0.enabled:           "true"
      versioning.0.mfa_delete:        "false"
      website_domain:                 <computed>
      website_endpoint:               <computed>


Plan: 7 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```