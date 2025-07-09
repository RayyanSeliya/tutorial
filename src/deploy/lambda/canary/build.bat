@echo off
REM Build script for PipeCD Tutorial Lambda Function (Canary) - Windows
REM This script packages the canary Lambda function code into a zip file

echo Building PipeCD Tutorial Lambda Function (Canary)...

REM Set variables
set BUILD_DIR=build
set FUNCTION_NAME=pipecd-tutorial-canary
set ZIP_FILE=%FUNCTION_NAME%.zip

REM Clean previous build
if exist "%BUILD_DIR%" (
    echo Cleaning previous build...
    rmdir /s /q "%BUILD_DIR%"
)

if exist "%ZIP_FILE%" (
    echo Removing previous zip file...
    del "%ZIP_FILE%"
)

REM Create build directory
mkdir "%BUILD_DIR%"

REM Copy source code
echo Copying source code...
copy "src\index.py" "%BUILD_DIR%\"

REM Check if requirements.txt has actual dependencies
findstr /v "^#" "src\requirements.txt" | findstr /v "^$" > nul
if %errorlevel% equ 0 (
    echo Installing Python dependencies...
    pip install -r src\requirements.txt -t %BUILD_DIR%
) else (
    echo No dependencies to install (using only standard library)
)

REM Create zip file
echo Creating zip package...
cd "%BUILD_DIR%"
powershell -command "Compress-Archive -Path * -DestinationPath '..\%ZIP_FILE%' -Force"
cd ..

REM Cleanup build directory
rmdir /s /q "%BUILD_DIR%"

echo ✅ Canary Lambda function packaged successfully: %ZIP_FILE%
for %%A in ("%ZIP_FILE%") do echo 📦 Package size: %%~zA bytes
echo.
echo Next steps:
echo 1. Upload %ZIP_FILE% to an S3 bucket
echo 2. Update function.yaml with the S3 bucket and key
echo 3. Deploy using PipeCD canary pipeline

pause
