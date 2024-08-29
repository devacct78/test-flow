#!/bin/bash

# Fetch repository name from CodeCommit
repo_url=$(aws codebuild batch-get-projects --names $CODEBUILD_PROJECT_NAME --query 'projects[0].source.location' --output text)
repo_name=$(basename $repo_url | sed 's/.git$//')

echo "Repository Name: $repo_name"
echo "Branch Ref: $CODEBUILD_SOURCE_VERSION"
echo "Build Number: $CODEBUILD_BUILD_NUMBER"

branch_name=$(echo $CODEBUILD_SOURCE_VERSION | sed 's/refs\/heads\///' | tr '[:upper:]' '[:lower:]')

# Handle edge cases where variables might be empty
if [ -z "$repo_name" ]; then
  echo "Error: Repository name could not be determined"
  exit 1
fi

if [ -z "$branch_name" ]; then
  echo "Error: CODEBUILD_SOURCE_VERSION is empty or not in expected format"
  exit 1
fi

instance_name="${repo_name}-${branch_name}-${CODEBUILD_BUILD_NUMBER}-ec2"
echo "Instance Name: $instance_name"

# Deploy CloudFormation stack
aws cloudformation deploy \
  --template-file ec2-instance.yaml \
  --stack-name my-ec2-stack-${CODEBUILD_BUILD_NUMBER} \
  --parameter-overrides InstanceName=$instance_name
