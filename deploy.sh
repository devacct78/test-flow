#!/bin/bash

echo "Repository Name: $CODEBUILD_SOURCE_REPO_NAME"
echo "Branch Ref: $CODEBUILD_SOURCE_VERSION"
echo "Build Number: $CODEBUILD_BUILD_NUMBER"

# Extract repo name and branch name
repo_name=$(echo $CODEBUILD_SOURCE_REPO_NAME | tr '[:upper:]' '[:lower:]')
branch_name=$(echo $CODEBUILD_SOURCE_VERSION | sed 's/refs\/heads\///' | tr '[:upper:]' '[:lower:]')

# Handle edge cases where variables might be empty
if [ -z "$repo_name" ]; then
  echo "Error: CODEBUILD_SOURCE_REPO_NAME is empty"
  exit 1
fi

if [ -z "$branch_name" ]; then
  echo "Error: CODEBUILD_SOURCE_VERSION is empty or not in expected format"
  exit 1
fi

# Construct instance name
instance_name="${repo_name}-${branch_name}-${CODEBUILD_BUILD_NUMBER}-ec2"
echo "Instance Name: $instance_name"

# Deploy CloudFormation stack
aws cloudformation deploy \
  --template-file ec2-instance.yaml \
  --stack-name my-ec2-stack-${CODEBUILD_BUILD_NUMBER} \
  --parameter-overrides InstanceName=$instance_name