#!/usr/bin/env bash

# http://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_AWSCLI.html
GREEN='\033[1;32m'
NORMAL='\033[0m'

echo -e "${GREEN}AUTHENTICATING WITH AWS${NORMAL}"

region="${AWS_REGION:-us-east-1}"

if [ -z "${AWS_PROFILE}" ]; then
    echo "An AWS_PROFILE environment variable is required!"
    exit 1
fi

if aws --version | grep -qF 'aws-cli/2'; then
    account_id="$(aws sts get-caller-identity | jq -r .Account).dkr.ecr.${region}.amazonaws.com"

    aws ecr get-login-password --region ${region} \
        | docker login --username AWS --password-stdin "${account_id}"
else
    $(aws ecr get-login --region ${region} --no-include-email)
fi
