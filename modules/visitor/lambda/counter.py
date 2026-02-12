import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['TABLE_NAME']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*', 
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type'
    }
    
    try:
        response = table.update_item(
            Key={'id': 'site_stats'},
            UpdateExpression='ADD visitor_count :inc',
            ExpressionAttributeValues={':inc': 1},
            ReturnValues='UPDATED_NEW'
        )
        
        new_count = int(response['Attributes']['visitor_count'])
        
        return {
            'statusCode': 200,
            'headers': headers, 
            'body': json.dumps({'count': new_count})
        }
        
    except Exception as e:
        print(f"Hata olustu: {str(e)}")
        return {
            'statusCode': 500,
            'headers': headers, 
            'body': json.dumps({'error': str(e)})
        }