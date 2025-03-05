#!/bin/bash

# Exit on error
set -e

# Configuration
APP_NAME="budgeting-application"
ENV_NAME="budgeting-application-env"
REGION="us-east-2"
S3_BUCKET="elasticbeanstalk-$REGION-$(aws sts get-caller-identity --query 'Account' --output text)"
VERSION="v$(date +%Y%m%d%H%M%S)"
ZIP_FILE="$APP_NAME-$VERSION.zip"

echo "Building application..."
mvn clean package

echo "Creating application bundle..."
mkdir -p .ebextensions
mkdir -p .elasticbeanstalk

# Create the application bundle
zip -r $ZIP_FILE Procfile .ebextensions target/*.jar src/main/resources

echo "Uploading application bundle to S3..."
aws s3 cp $ZIP_FILE s3://$S3_BUCKET/$ZIP_FILE

# Check if the application exists
if ! aws elasticbeanstalk describe-applications --application-names $APP_NAME --region $REGION > /dev/null 2>&1; then
    echo "Creating Elastic Beanstalk application..."
    aws elasticbeanstalk create-application --application-name $APP_NAME --region $REGION
fi

# Check if the environment exists
if ! aws elasticbeanstalk describe-environments --environment-names $ENV_NAME --region $REGION --query 'Environments[0].Status' --output text > /dev/null 2>&1; then
    echo "Creating Elastic Beanstalk environment..."
    aws elasticbeanstalk create-environment \
        --application-name $APP_NAME \
        --environment-name $ENV_NAME \
        --solution-stack-name "64bit Amazon Linux 2 v3.5.0 running Corretto 11" \
        --region $REGION \
        --option-settings file://.elasticbeanstalk/options.json
else
    echo "Updating Elastic Beanstalk environment..."
    aws elasticbeanstalk update-environment \
        --environment-name $ENV_NAME \
        --region $REGION \
        --version-label $VERSION
fi

echo "Creating application version..."
aws elasticbeanstalk create-application-version \
    --application-name $APP_NAME \
    --version-label $VERSION \
    --source-bundle S3Bucket=$S3_BUCKET,S3Key=$ZIP_FILE \
    --region $REGION \
    --auto-create-application

echo "Deploying application version..."
aws elasticbeanstalk update-environment \
    --environment-name $ENV_NAME \
    --version-label $VERSION \
    --region $REGION

echo "Deployment initiated. Check the AWS Elastic Beanstalk console for status."
echo "URL: https://$ENV_NAME.$REGION.elasticbeanstalk.com"
