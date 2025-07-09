@echo off
REM Quick setup script for PipeCD Lambda Tutorial (Windows)
REM This script helps you get started with Lambda deployment quickly

echo 🚀 PipeCD Lambda Tutorial Setup
echo ================================

REM Check prerequisites
echo 📋 Checking prerequisites...

REM Check AWS CLI
aws --version >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ AWS CLI not found or not working. Please install AWS CLI first.
    echo 💡 You can install it from: https://aws.amazon.com/cli/
    echo 💡 Or try: winget install Amazon.AWSCLI
    pause
    exit /b 1
)

REM Check Python
python --version >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Python not found. Please install Python 3.9+ first.
    echo 💡 You can install it from: https://python.org/downloads/
    echo 💡 Or try: winget install Python.Python.3.12
    pause
    exit /b 1
)

REM Check if AWS is configured
aws sts get-caller-identity >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ AWS CLI not configured. Please run 'aws configure' first.
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed!

REM Get user inputs
echo.
echo 📝 Configuration
echo ==================

set /p S3_BUCKET="Enter your S3 bucket name for Lambda packages: "
set /p LAMBDA_ROLE="Enter your Lambda execution role ARN: "

REM Validate inputs
if "%S3_BUCKET%"=="" (
    echo ❌ S3 bucket name is required.
    pause
    exit /b 1
)

if "%LAMBDA_ROLE%"=="" (
    echo ❌ Lambda role ARN is required.
    pause
    exit /b 1
)

REM Check if S3 bucket exists
aws s3 ls "s3://%S3_BUCKET%" >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️  S3 bucket '%S3_BUCKET%' not found or not accessible.
    set /p CREATE_BUCKET="Do you want to create it? (y/n): "
    if /i "%CREATE_BUCKET%"=="y" (
        echo Creating S3 bucket...
        aws s3 mb "s3://%S3_BUCKET%"
        if %errorlevel% equ 0 (
            echo ✅ S3 bucket created successfully!
        ) else (
            echo ❌ Failed to create S3 bucket.
            pause
            exit /b 1
        )
    ) else (
        echo ❌ Please create the S3 bucket first or check permissions.
        pause
        exit /b 1
    )
)

REM Build and deploy simple function
echo.
echo 🏗️  Building Simple Lambda Function
echo ====================================

cd simple

REM Update function.yaml
echo Updating function.yaml...
powershell -command "(Get-Content function.yaml) -replace '<S3_BUCKET_NAME>', '%S3_BUCKET%' | Set-Content function.yaml"
powershell -command "(Get-Content function.yaml) -replace '<S3_KEY_PATH>', 'lambda/pipecd-tutorial-simple.zip' | Set-Content function.yaml"
powershell -command "(Get-Content function.yaml) -replace '<IAM_ROLE_ARN>', '%LAMBDA_ROLE%' | Set-Content function.yaml"

REM Build package
echo Building package...
call build.bat

REM Upload to S3
echo Uploading to S3...
aws s3 cp pipecd-tutorial-simple.zip "s3://%S3_BUCKET%/lambda/pipecd-tutorial-simple.zip"

echo ✅ Simple function setup complete!

REM Build and deploy canary function
echo.
echo 🏗️  Building Canary Lambda Function
echo ====================================

cd ..\canary

REM Update function.yaml
echo Updating function.yaml...
powershell -command "(Get-Content function.yaml) -replace '<S3_BUCKET_NAME>', '%S3_BUCKET%' | Set-Content function.yaml"
powershell -command "(Get-Content function.yaml) -replace '<S3_KEY_PATH>', 'lambda/pipecd-tutorial-canary.zip' | Set-Content function.yaml"
powershell -command "(Get-Content function.yaml) -replace '<IAM_ROLE_ARN>', '%LAMBDA_ROLE%' | Set-Content function.yaml"

REM Build package
echo Building package...
call build.bat

REM Upload to S3
echo Uploading to S3...
aws s3 cp pipecd-tutorial-canary.zip "s3://%S3_BUCKET%/lambda/pipecd-tutorial-canary.zip"

echo ✅ Canary function setup complete!

REM Summary
echo.
echo 🎉 Setup Complete!
echo ==================
echo ✅ Both Lambda functions are built and uploaded to S3
echo ✅ Configuration files are updated
echo.
echo 📋 Next Steps:
echo 1. Commit and push your changes to Git
echo 2. Register the applications in PipeCD console
echo 3. Watch the deployment progress
echo.
echo 📁 Files created:
echo - simple\pipecd-tutorial-simple.zip
echo - canary\pipecd-tutorial-canary.zip
echo.
echo ☁️  S3 Objects:
echo - s3://%S3_BUCKET%/lambda/pipecd-tutorial-simple.zip
echo - s3://%S3_BUCKET%/lambda/pipecd-tutorial-canary.zip
echo.
echo 📚 For more information, see:
echo - README.md
echo - DEPLOYMENT_GUIDE.md

pause
