"""
Canary Lambda function for PipeCD Tutorial

This is a Lambda function for demonstrating canary deployments with PipeCD.
It includes version information and enhanced logging for deployment tracking.
"""

import json
import os
from datetime import datetime, timezone


def lambda_handler(event, context):
    """
    AWS Lambda handler function for canary deployment demo
    
    Args:
        event: The event dict that contains the request data
        context: The context object that contains runtime information
        
    Returns:
        dict: Response object with statusCode, headers, and body
    """
    
    # Get environment variables
    function_name = context.function_name if context else "unknown"
    version = os.environ.get('FUNCTION_VERSION', 'v2.0.0')
    deployment_type = os.environ.get('DEPLOYMENT_TYPE', 'canary')
    
    # Create response message with canary-specific information
    message = {
        "greeting": "Hello from PipeCD Tutorial Lambda (Canary)!",
        "function_name": function_name,
        "version": version,
        "deployment_type": deployment_type,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "canary_info": {
            "strategy": "gradual rollout",
            "traffic_percentage": "controlled by PipeCD pipeline"
        },
        "event_info": {
            "http_method": event.get("httpMethod", "N/A"),
            "path": event.get("path", "N/A"),
            "query_params": event.get("queryStringParameters") or {}
        }
    }
    
    # Enhanced logging for canary deployment tracking
    print(f"🚀 Canary deployment - Processing request for {function_name} version {version}")
    print(f"📊 Deployment type: {deployment_type}")
    print(f"📝 Event: {json.dumps(event, default=str)}")
    
    # Return response with canary-specific headers
    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
            "X-Function-Version": version,
            "X-Deployment-Type": deployment_type
        },
        "body": json.dumps(message, indent=2)
    }
    
    return response


# For local testing
if __name__ == "__main__":
    # Test event
    test_event = {
        "httpMethod": "GET",
        "path": "/canary-test",
        "queryStringParameters": {"deployment": "canary"}
    }
    
    # Mock context
    class MockContext:
        function_name = "pipecd-tutorial-canary-local"
        
    result = lambda_handler(test_event, MockContext())
    print("Canary test result:")
    print(json.dumps(result, indent=2))
