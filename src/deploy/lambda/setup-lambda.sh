#!/bin/bash

# Quick setup script for PipeCD Lambda Tutorial
# This script helps you get started with Lambda deployment quickly

set -e

echo "🚀 PipeCD Lambda Tutorial Setup"
echo "================================"

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.9+ first."
    exit 1
fi

# Check if AWS is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed!"

# Get user inputs
echo ""
echo "📝 Configuration"
echo "=================="

read -p "Enter your S3 bucket name for Lambda packages: " S3_BUCKET
read -p "Enter your Lambda execution role ARN: " LAMBDA_ROLE

# Validate inputs
if [ -z "$S3_BUCKET" ] || [ -z "$LAMBDA_ROLE" ]; then
    echo "❌ S3 bucket name and Lambda role ARN are required."
    exit 1
fi

# Check if S3 bucket exists
if ! aws s3 ls "s3://$S3_BUCKET" &> /dev/null; then
    echo "⚠️  S3 bucket '$S3_BUCKET' not found or not accessible."
    read -p "Do you want to create it? (y/n): " CREATE_BUCKET
    if [ "$CREATE_BUCKET" = "y" ] || [ "$CREATE_BUCKET" = "Y" ]; then
        echo "Creating S3 bucket..."
        aws s3 mb "s3://$S3_BUCKET"
        echo "✅ S3 bucket created successfully!"
    else
        echo "❌ Please create the S3 bucket first or check permissions."
        exit 1
    fi
fi

# Build and deploy simple function
echo ""
echo "🏗️  Building Simple Lambda Function"
echo "===================================="

cd simple/

# Update function.yaml
echo "Updating function.yaml..."
sed -i.bak "s|<S3_BUCKET_NAME>|$S3_BUCKET|g" function.yaml
sed -i.bak "s|<S3_KEY_PATH>|lambda/pipecd-tutorial-simple.zip|g" function.yaml
sed -i.bak "s|<IAM_ROLE_ARN>|$LAMBDA_ROLE|g" function.yaml

# Build package
echo "Building package..."
chmod +x build.sh
./build.sh

# Upload to S3
echo "Uploading to S3..."
aws s3 cp pipecd-tutorial-simple.zip "s3://$S3_BUCKET/lambda/pipecd-tutorial-simple.zip"

echo "✅ Simple function setup complete!"

# Build and deploy canary function
echo ""
echo "🏗️  Building Canary Lambda Function"
echo "===================================="

cd ../canary/

# Update function.yaml
echo "Updating function.yaml..."
sed -i.bak "s|<S3_BUCKET_NAME>|$S3_BUCKET|g" function.yaml
sed -i.bak "s|<S3_KEY_PATH>|lambda/pipecd-tutorial-canary.zip|g" function.yaml
sed -i.bak "s|<IAM_ROLE_ARN>|$LAMBDA_ROLE|g" function.yaml

# Build package
echo "Building package..."
chmod +x build.sh
./build.sh

# Upload to S3
echo "Uploading to S3..."
aws s3 cp pipecd-tutorial-canary.zip "s3://$S3_BUCKET/lambda/pipecd-tutorial-canary.zip"

echo "✅ Canary function setup complete!"

# Summary
echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo "✅ Both Lambda functions are built and uploaded to S3"
echo "✅ Configuration files are updated"
echo ""
echo "📋 Next Steps:"
echo "1. Commit and push your changes to Git"
echo "2. Register the applications in PipeCD console"
echo "3. Watch the deployment progress"
echo ""
echo "📁 Files created:"
echo "- simple/pipecd-tutorial-simple.zip"
echo "- canary/pipecd-tutorial-canary.zip"
echo ""
echo "☁️  S3 Objects:"
echo "- s3://$S3_BUCKET/lambda/pipecd-tutorial-simple.zip"
echo "- s3://$S3_BUCKET/lambda/pipecd-tutorial-canary.zip"
echo ""
echo "📚 For more information, see:"
echo "- README.md"
echo "- DEPLOYMENT_GUIDE.md"
