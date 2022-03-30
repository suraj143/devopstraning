ECR_REGISTRY='928814396842.dkr.ecr.us-east-1.amazonaws.com'      ## Change with registry name
AWS_REGION='us-east-1'
ECR_REPO=siju123                                                 ## Change with repo. We can also make repository list creation as a for loop
 
##Login to ECR
aws ecr get-login-password --region $AWS_REGION  | docker login --username AWS --password-stdin $ECR_REGISTRY
 
 
IMAGE_TAGS=$(aws ecr list-images --repository-name $ECR_REPO --query 'imageIds[].imageTag' --output text $profile)
 
#For each repository tag, recreate the tag to simulate tag push action
for image_tag in $IMAGE_TAGS
do
    MANIFEST=$(aws ecr batch-get-image --repository-name $ECR_REPO  --image-id imageTag=$image_tag  --query 'images[].imageManifest' --output text $profile)
    echo $MANIFEST
    new_tag=$image_tag".temp"
    echo "copying image $ECR_REPO:$image_tag"
    aws ecr put-image --repository-name $ECR_REPO --image-tag $new_tag --image-manifest "$MANIFEST"  $profile
    aws ecr batch-delete-image --repository-name $ECR_REPO  --image-ids imageTag=$image_tag  $profile
    aws ecr put-image --repository-name $ECR_REPO --image-tag $image_tag --image-manifest "$MANIFEST" $profile
    aws ecr batch-delete-image --repository-name $ECR_REPO --image-ids imageTag=$new_tag  $profile
done
