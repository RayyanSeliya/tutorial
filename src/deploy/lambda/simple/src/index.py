"""
Simple Lambda function for PipeCD Tutorial

This is a basic Lambda function that demonstrates deployment with PipeCD.
It returns a simple JSON response with a greeting message.
"""

import json
import os
from datetime import datetime, timezone


def lambda_handler(event, context):
    """
    AWS Lambda handler function
    
    Args:
        event: The event dict that contains the request data
        context: The context object that contains runtime information
        
    Returns:
        dict: Response object with statusCode, headers, and body
    """
    
    # Get environment variables
    function_name = context.function_name if context else "unknown"
    version = os.environ.get('FUNCTION_VERSION', 'v1.0.0')
    
    # Create response message
    message = {
        "greeting": "Hello from PipeCD Tutorial Lambda!",
        "function_name": function_name,
        "version": version,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "event_info": {
            "http_method": event.get("httpMethod", "N/A"),
            "path": event.get("path", "N/A"),
            "query_params": event.get("queryStringParameters") or {}
        }
    }
    
    # Log the request
    print(f"Processing request for {function_name} version {version}")
    print(f"Event: {json.dumps(event, default=str)}")
    
    # Return response
    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
        },
        "body": json.dumps(message, indent=2)
    }
    
    return response


# For local testing
if __name__ == "__main__":
    # Test event
    test_event = {
        "httpMethod": "GET",
        "path": "/test",
        "queryStringParameters": {"name": "PipeCD"}
    }
    
    # Mock context
    class MockContext:
        function_name = "pipecd-tutorial-local"
        
    result = lambda_handler(test_event, MockContext())
    print("Test result:")
    print(json.dumps(result, indent=2))
