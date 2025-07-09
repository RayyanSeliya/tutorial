# Lambda Deployment with PipeCD Tutorial

This directory contains examples for deploying AWS Lambda functions using PipeCD with **zip file deployment** instead of container images, making it much easier to get started.

## 🎯 What's New (Issue #16)

Previously, the Lambda tutorial required:
- ❌ Building and pushing container images to ECR
- ❌ Complex Docker setup
- ❌ ECR repository management

Now it uses:
- ✅ Simple Python source code
- ✅ Zip file packaging
- ✅ Direct S3 upload
- ✅ Minimal prerequisites

## 📁 Directory Structure

```
lambda/
├── simple/                 # Simple deployment example
│   ├── src/
│   │   ├── index.py       # Lambda function source code
│   │   └── requirements.txt # Python dependencies
│   ├── function.yaml      # Lambda function configuration
│   ├── app.pipecd.yaml   # PipeCD application config
│   ├── build.sh          # Build script (Linux/Mac)
│   └── build.bat         # Build script (Windows)
├── canary/                # Canary deployment example
│   ├── src/
│   │   ├── index.py       # Enhanced Lambda function
│   │   └── requirements.txt # Python dependencies
│   ├── function.yaml      # Lambda function configuration
│   ├── app.pipecd.yaml   # PipeCD canary pipeline config
│   ├── build.sh          # Build script (Linux/Mac)
│   └── build.bat         # Build script (Windows)
└── README.md             # This file
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **S3 bucket** for storing Lambda zip files
3. **IAM role** for Lambda execution
4. **Python 3.9+** (for local testing)

### Step 1: Build the Lambda Package

**Linux/Mac:**
```bash
cd simple/
chmod +x build.sh
./build.sh
```

**Windows:**
```cmd
cd simple\
build.bat
```

This creates `pipecd-tutorial-simple.zip` containing your Lambda function.

### Step 2: Upload to S3

```bash
aws s3 cp pipecd-tutorial-simple.zip s3://your-bucket-name/lambda/pipecd-tutorial-simple.zip
```

### Step 3: Configure function.yaml

Edit `simple/function.yaml`:

```yaml
spec:
  name: PipeCDTutorial_Simple
  role: arn:aws:iam::123456789012:role/lambda-execution-role
  source:
    s3Bucket: your-bucket-name
    s3Key: lambda/pipecd-tutorial-simple.zip
  runtime: python3.9
  handler: index.lambda_handler
```

### Step 4: Deploy with PipeCD

Follow the main tutorial instructions to register and deploy the application.

## 📋 Function Details

### Simple Function (`simple/src/index.py`)

- Returns a JSON response with greeting and metadata
- Includes request information and timestamps
- Uses only Python standard library (no dependencies)
- Perfect for testing basic Lambda deployment

### Canary Function (`canary/src/index.py`)

- Enhanced version with deployment tracking
- Additional logging for canary deployment monitoring
- Environment variables for version control
- Demonstrates gradual rollout capabilities

## 🔧 Customization

### Adding Dependencies

1. Edit `src/requirements.txt`:
   ```
   requests==2.31.0
   boto3==1.34.0
   ```

2. Rebuild the package:
   ```bash
   ./build.sh
   ```

### Modifying the Function

1. Edit `src/index.py` with your custom logic
2. Test locally: `python src/index.py`
3. Rebuild and redeploy

### Environment Variables

Add environment variables in `function.yaml`:

```yaml
spec:
  environment:
    CUSTOM_VAR: "custom_value"
    API_ENDPOINT: "https://api.example.com"
```

## 🧪 Local Testing

Test your function locally before deployment:

```bash
cd simple/src/
python index.py
```

This runs the function with a test event and displays the output.

## 📊 Deployment Strategies

### Simple Deployment
- Uses `simple/` directory
- Quick sync strategy
- Immediate deployment

### Canary Deployment
- Uses `canary/` directory
- Gradual traffic shifting (10% → 50% → 100%)
- Built-in rollback capabilities
- Wait stages for monitoring

## 🔍 Troubleshooting

### Build Issues
- Ensure Python 3.9+ is installed
- Check file permissions on build scripts
- Verify requirements.txt syntax

### Deployment Issues
- Confirm S3 bucket permissions
- Verify IAM role has Lambda execution permissions
- Check function.yaml syntax

### Runtime Issues
- Review CloudWatch logs
- Test function locally first
- Verify environment variables

## 📚 Next Steps

1. Try the simple deployment first
2. Experiment with the canary deployment
3. Customize the function for your use case
4. Explore PipeCD's advanced Lambda features

For more information, see the [PipeCD Lambda documentation](https://pipecd.dev/docs/user-guide/configuration-reference/#lambda-application).
