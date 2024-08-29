#!/bin/bash

echo "Branch Ref: $CODEBUILD_SOURCE_VERSION"
echo "Build Number: $CODEBUILD_BUILD_NUMBER"

# Use a static name for the repository
repo_name="test-flow"
branch_name=$(echo $CODEBUILD_SOURCE_VERSION | sed 's/refs\/heads\///' | tr '[:upper:]' '[:lower:]')

# Handle edge cases where variables might be empty
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
