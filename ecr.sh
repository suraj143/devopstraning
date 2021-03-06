#!/bin/bash
SOURCE_DESTINATION=us-east-1
ACCOUNT=928814396842
DESTINATION_REGION=us-west-2
REPO_NAME=configurationapi

REPOSITORIES=$(aws ecr --region=${SOURCE_DESTINATION} describe-repositories | jq -r 'map(.[] | .repositoryName ) | join(" ")')
echo $REPOSITORIES

for repo in $REPOSITORIES; do
      aws ecr get-login-password --region ${SOURCE_DESTINATION}  | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$SOURCE_DESTINATION.amazonaws.com
      aws ecr list-images --repository-name $REPO_NAME --query 'imageIds[].imageTag' --region $SOURCE_DESTINATION

    TAGS=$(aws ecr --region $SOURCE_DESTINATION list-images --repository-name $REPO_NAME | jq -r 'map(.[] | .imageTag) | join(" ")')
	for tag in $TAGS; do
           docker pull $ACCOUNT.dkr.ecr.$SOURCE_DESTINATION.amazonaws.com/$REPO_NAME:$tag
           echo "Pull complete"

           echo "docker login $DESTINATION_REGION"
           aws ecr get-login-password --region $DESTINATION_REGION | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$DESTINATION_REGION.amazonaws.com

           echo "Creating $REPO_NAME in $DESTINATION_REGION"
`	   aws ecr --region $DESTINATION_REGION create-repository --repository-name $REPO_NAME || true

           docker tag $ACCOUNT.dkr.ecr.$SOURCE_DESTINATION.amazonaws.com/$REPO_NAME:$tag $ACCOUNT.dkr.ecr.$DESTINATION_REGION.amazonaws.com/$REPO_NAME:$tag
           echo "Tag complete"
           docker push $ACCOUNT.dkr.ecr.$DESTINATION_REGION.amazonaws.com/$REPO_NAME:$tag
           echo "Push complete"
	   echo "List all docker images in $DESTINATION_REGION"
           aws ecr --region $DESTINATION_REGION list-images --repository-name $REPO_NAME | jq -r 'map(.[] | .imageTag) | join(" ")'
      done
done

