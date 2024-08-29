#!/bin/bash

# Ensure Git is available
if ! command -v git &> /dev/null
then
    echo "Git could not be found"
    exit 1
fi

# Fetch repository name using Git commands
repo_url=$(git config --get remote.origin.url)
repo_name=$(basename "$repo_url" .git)
echo "Repository Name: $repo_name"

# Fetch branch name
branch_name=$(echo $CODEBUILD_SOURCE_VERSION | sed 's/refs\/heads\///' | tr '[:upper:]' '[:lower:]')
echo "Branch Ref: $branch_name"
echo "Build Number: $CODEBUILD_BUILD_NUMBER"

# Handle edge cases where variables might be empty
if [ -z "$repo_name" ]; then
  echo "Error: Repository name could not be determined"
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
