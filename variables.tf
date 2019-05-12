variable "handler" {
  default = "lambda.handler"
}

variable "region" {}

variable "runtime" {
  default = "python3.7"
}

variable "schedule_midnight" {
  default = "cron(0 0 * * ? *)"
}
