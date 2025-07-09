# 🚀 Complete Lambda Deployment Guide

This guide provides step-by-step instructions for deploying AWS Lambda functions with PipeCD using the new simplified zip-based approach.

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] AWS CLI configured with appropriate permissions
- [ ] S3 bucket created for storing Lambda packages
- [ ] IAM role for Lambda execution with basic permissions
- [ ] Python 3.9+ installed locally
- [ ] PipeCD control plane and piped running

## 🔧 Setup Instructions

### 1. Create S3 Bucket (if not exists)

```bash
# Create bucket
aws s3 mb s3://your-lambda-bucket-name

# Enable versioning (recommended)
aws s3api put-bucket-versioning \
  --bucket your-lambda-bucket-name \
  --versioning-configuration Status=Enabled
```

### 2. Create IAM Role for Lambda

Create a trust policy file `lambda-trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Create the role:

```bash
# Create role
aws iam create-role \
  --role-name pipecd-lambda-execution-role \
  --assume-role-policy-document file://lambda-trust-policy.json

# Attach basic execution policy
aws iam attach-role-policy \
  --role-name pipecd-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Get role ARN (save this for later)
aws iam get-role --role-name pipecd-lambda-execution-role --query 'Role.Arn' --output text
```

## 🏗️ Building and Deploying

### Simple Deployment

1. **Navigate to simple directory:**
   ```bash
   cd src/deploy/lambda/simple/
   ```

2. **Build the package:**
   ```bash
   # Linux/Mac
   chmod +x build.sh
   ./build.sh
   
   # Windows
   build.bat
   ```

3. **Upload to S3:**
   ```bash
   aws s3 cp pipecd-tutorial-simple.zip s3://your-lambda-bucket-name/lambda/pipecd-tutorial-simple.zip
   ```

4. **Configure function.yaml:**
   ```yaml
   spec:
     name: PipeCDTutorial_Simple
     role: arn:aws:iam::123456789012:role/pipecd-lambda-execution-role
     source:
       s3Bucket: your-lambda-bucket-name
       s3Key: lambda/pipecd-tutorial-simple.zip
     runtime: python3.9
     handler: index.lambda_handler
     memory: 512
     timeout: 30
     environment:
       FUNCTION_VERSION: "v1.0.0"
   ```

5. **Deploy with PipeCD:**
   - Register the application in PipeCD console
   - Commit and push changes to trigger deployment

### Canary Deployment

1. **Navigate to canary directory:**
   ```bash
   cd src/deploy/lambda/canary/
   ```

2. **Build the package:**
   ```bash
   # Linux/Mac
   chmod +x build.sh
   ./build.sh
   
   # Windows
   build.bat
   ```

3. **Upload to S3:**
   ```bash
   aws s3 cp pipecd-tutorial-canary.zip s3://your-lambda-bucket-name/lambda/pipecd-tutorial-canary.zip
   ```

4. **Configure function.yaml:**
   ```yaml
   spec:
     name: PipeCDTutorial_Canary
     role: arn:aws:iam::123456789012:role/pipecd-lambda-execution-role
     source:
       s3Bucket: your-lambda-bucket-name
       s3Key: lambda/pipecd-tutorial-canary.zip
     runtime: python3.9
     handler: index.lambda_handler
     memory: 512
     timeout: 30
     environment:
       FUNCTION_VERSION: "v2.0.0"
       DEPLOYMENT_TYPE: "canary"
   ```

5. **Deploy with canary strategy:**
   - The pipeline will automatically handle gradual rollout
   - Monitor deployment progress in PipeCD console

## 🧪 Testing Your Deployment

### Local Testing

Test the function locally before deployment:

```bash
cd src/
python index.py
```

### AWS Testing

After deployment, test the function:

```bash
# Invoke function directly
aws lambda invoke \
  --function-name PipeCDTutorial_Simple \
  --payload '{"httpMethod":"GET","path":"/test"}' \
  response.json

# View response
cat response.json
```

## 🔍 Troubleshooting

### Common Issues

1. **Build fails:**
   - Check Python version: `python --version`
   - Ensure build script has execute permissions
   - Verify requirements.txt syntax

2. **Upload fails:**
   - Check AWS credentials: `aws sts get-caller-identity`
   - Verify S3 bucket exists and you have write permissions
   - Check bucket region matches your AWS CLI region

3. **Deployment fails:**
   - Verify IAM role ARN is correct
   - Check S3 bucket and key path in function.yaml
   - Ensure Lambda service has access to S3 bucket

4. **Function errors:**
   - Check CloudWatch logs: `aws logs describe-log-groups --log-group-name-prefix /aws/lambda/PipeCDTutorial`
   - Verify handler path: `index.lambda_handler`
   - Check runtime compatibility

### Debugging Commands

```bash
# Check function configuration
aws lambda get-function --function-name PipeCDTutorial_Simple

# View recent logs
aws logs tail /aws/lambda/PipeCDTutorial_Simple --follow

# Test function with custom payload
aws lambda invoke \
  --function-name PipeCDTutorial_Simple \
  --payload '{"test": "data"}' \
  --cli-binary-format raw-in-base64-out \
  response.json
```

## 🎯 Next Steps

1. **Customize the function** for your specific use case
2. **Add dependencies** by editing requirements.txt
3. **Implement monitoring** using CloudWatch metrics
4. **Set up alerts** for function errors
5. **Explore advanced PipeCD features** like approval workflows

## 📚 Additional Resources

- [PipeCD Lambda Documentation](https://pipecd.dev/docs/user-guide/configuration-reference/#lambda-application)
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/)
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
