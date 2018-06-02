#!/usr/bin/env bash

_AWS_REGION=ap-northeast-1
_AWS_PROFILE=${1}
_STACK_NAME_PREFIX=${2}
_ENV=${3}
_ACTION=${4}
_CMD_NAME=$(basename $0)

function usage(){
  echo "Usage: ${_CMD_NAME} [aws_profile_name] [stack_name_prefix] [debug|dev|stg|prd] [create|update|delete|validate]" 1>&2
}

if [ $# != 4 ]; then
  usage
  exit 1
fi

function create_stack() {
  aws --profile=${_AWS_PROFILE} --region=${_AWS_REGION} \
    cloudformation create-stack \
      --stack-name ${_ENV}-${_STACK_NAME_PREFIX} \
      --parameters file://parameters/${_ENV}.json \
      --template-body file://template.yml \
      --capabilities CAPABILITY_IAM
  aws --profile=${_AWS_PROFILE} --region=${_AWS_REGION} \
    cloudformation wait stack-create-complete \
      --stack-name ${_ENV}-${_STACK_NAME_PREFIX} \
  ; [ $? = 0 ] && echo "Create Stack Success." || echo "Create Stack Failure."
}

function update_stack() {
  aws --profile=${_AWS_PROFILE} --region=${_AWS_REGION} \
    cloudformation update-stack \
      --stack-name ${_ENV}-${_STACK_NAME_PREFIX} \
      --parameters file://parameters/${_ENV}.json \
      --template-body file://template.yml \
      --capabilities CAPABILITY_IAM
  aws --profile=${_AWS_PROFILE} --region=${_AWS_REGION} \
    cloudformation wait stack-update-complete \
      --stack-name ${_ENV}-${_STACK_NAME_PREFIX} \
  ; [ $? = 0 ] && echo "Update Stack Success." || echo "Update Stack Failure."
}

function delete_stack() {
  aws --profile=${_AWS_PROFILE} --region=${_AWS_REGION} \
    cloudformation delete-stack \
      --stack-name ${_ENV}-${_STACK_NAME_PREFIX}
  aws --profile=${_AWS_PROFILE} --region=${_AWS_REGION} \
    cloudformation wait stack-delete-complete \
      --stack-name ${_ENV}-${_STACK_NAME_PREFIX} \
  ; [ $? = 0 ] && echo "Delete Stack Success." || echo "Delete Stack Failure."
}

function validate_template() {
  aws --region=${_AWS_REGION} \
    cloudformation validate-template \
      --template-body file://template.yml > /dev/null \
  ; [ $? = 0 ] && echo "Template validated Success." || echo "Template validate Failure."
}

case "${_ACTION}" in
  "create" ) create_stack ;;
  "update" ) update_stack ;;
  "delete" ) delete_stack ;;
  "validate" ) validate_template ;;
esac
