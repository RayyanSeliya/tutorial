#!/bin/bash

# Build script for PipeCD Tutorial Lambda Function (Canary)
# This script packages the canary Lambda function code into a zip file

set -e

echo "Building PipeCD Tutorial Lambda Function (Canary)..."

# Create build directory
BUILD_DIR="build"
FUNCTION_NAME="pipecd-tutorial-canary"
ZIP_FILE="${FUNCTION_NAME}.zip"

# Clean previous build
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

if [ -f "$ZIP_FILE" ]; then
    echo "Removing previous zip file..."
    rm "$ZIP_FILE"
fi

# Create build directory
mkdir -p "$BUILD_DIR"

# Copy source code
echo "Copying source code..."
cp src/index.py "$BUILD_DIR/"

# Install dependencies if requirements.txt has actual dependencies
if [ -f "src/requirements.txt" ] && [ -s "src/requirements.txt" ] && grep -v '^#' src/requirements.txt | grep -v '^$' > /dev/null; then
    echo "Installing Python dependencies..."
    pip install -r src/requirements.txt -t "$BUILD_DIR/"
else
    echo "No dependencies to install (using only standard library)"
fi

# Create zip file
echo "Creating zip package..."
cd "$BUILD_DIR"

# Check if we're on Windows (Git Bash) and use PowerShell for zip
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Use PowerShell to create zip on Windows
    powershell.exe -command "Compress-Archive -Path * -DestinationPath '../$ZIP_FILE' -Force"
else
    # Use standard zip command on Linux/Mac
    zip -r "../$ZIP_FILE" .
fi

cd ..

# Cleanup build directory
rm -rf "$BUILD_DIR"

echo "✅ Canary Lambda function packaged successfully: $ZIP_FILE"
echo "📦 Package size: $(du -h "$ZIP_FILE" | cut -f1)"
echo ""
echo "Next steps:"
echo "1. Upload $ZIP_FILE to an S3 bucket"
echo "2. Update function.yaml with the S3 bucket and key"
echo "3. Deploy using PipeCD canary pipeline"
