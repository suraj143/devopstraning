#!/bin/bash
REPOSITORIES=$(aws ecr --region=$1 describe-repositories | jq -r 'map(.[] | .repositoryName ) | join(" ")')

for repo in $REPOSITORIES; do
	 aws ecr get-login-password --region $1 | docker login --username AWS --password-stdin $3.dkr.ecr.$1.amazonaws.com
         TAGS=$(aws ecr --region $1 list-images --repository-name $repo | jq -r 'map(.[] | .imageTag) | join(" ")')

      for tag in $TAGS; do
           docker pull $3.dkr.ecr.$1.amazonaws.com/$repo:$tag
           echo "Pull complete"

           echo "Creating a repository for $repo in $2 region"
	   aws ecr get-login-password --region $2 | docker login --username AWS --password-stdin $3.dkr.ecr.$2.amazonaws.com
           aws ecr --region $2 describe-repositories --repository-names $repo || aws ecr --region $2 create-repository --repository-name $repo

           docker tag $3.dkr.ecr.$1.amazonaws.com/$repo:$tag $3.dkr.ecr.$2.amazonaws.com/$repo:$tag
           echo "Tag complete"

           docker push $3.dkr.ecr.$2.amazonaws.com/$repo:$tag
           echo "Push complete"

      done
done
           docker rm -f $(docker ps -aq)
           docker rmi -f $(docker images -aq)
           echo "Clear Workspace of docker images"

