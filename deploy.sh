#!/usr/bin/env bash
export PKG_DIR="python"
export PY_VERSION="python3.7"

printf "\033[1;33m[1/3] Creating packages for Lambda \033[0m\n"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LAMBDA_DIR="sources/lambda-functions"
FULL_DIR=${SCRIPT_DIR}/${LAMBDA_DIR}
printf "\033[1;35m> Checking for Lambda functions in ${FULL_DIR} \033[0m\n"
for fldr in ${FULL_DIR}/*
do
    printf "\033[1;35m>> Zipping ${fldr} \033[0m\n"
    cd ${fldr} && rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR}
    docker run --rm -v $(pwd):/foo -w /foo lambci/lambda:build-${PY_VERSION} \
    pip install -r requirements.txt -t ${PKG_DIR} --no-deps
    cd ${fldr}/${PKG_DIR}
    find . -type d -name '__pycache__' -print0 | xargs -0 rm -rf
    rm ${fldr}/lambda.zip && zip --quiet -r ${fldr}/lambda.zip .
    cd ${fldr} && zip --quiet -r ${fldr}/lambda.zip lambda.py
    rm -rf ${fldr}/${PKG_DIR}
done
cd ${SCRIPT_DIR}

printf "\033[1;33m[2/3] Deploying on AWS\033[0m\n"
terraform apply

printf "\033[1;33m[3/3] Executing the initial run script\033[0m\n"
${PY_VERSION} initial_run.py
