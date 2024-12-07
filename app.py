from flask import Flask, jsonify, request
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

app = Flask(__name__)

# AWS S3 client
s3_client = boto3.client('s3')
BUCKET_NAME = 'anigaikwadbucket16'  # Replace with your actual S3 bucket name

@app.route('/list-bucket-content', defaults={'path': ''}, methods=['GET'])
@app.route('/list-bucket-content/<path:path>', methods=['GET'])
def list_bucket_content(path):
    try:
        if path:
            # List objects under the specified prefix
            response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix=path + '/', Delimiter='/')
        else:
            # List top-level objects
            response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Delimiter='/')

        # Handle the case where no objects are found
        if response.get('KeyCount', 0) == 0:
            return jsonify({"error": "Path does not exist"}), 404

        # Parse response to get folders and files
        folders = [prefix['Prefix'].rstrip('/') for prefix in response.get('CommonPrefixes', [])]
        files = [obj['Key'] for obj in response.get('Contents', []) if obj['Key'] != path + '/']

        return jsonify({"content": folders + files})

    #except NoCredentialsError:
     #   return jsonify({"error": "AWS credentials not found. Please configure them using 'aws configure'."}), 500

    #except PartialCredentialsError:
     #   return jsonify({"error": "Incomplete AWS credentials. Please verify your access key and secret key."}), 500 

    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'AccessDenied':
            return jsonify({"error": "Access Denied. Check your S3 bucket permissions."}), 403
        elif error_code == 'NoSuchBucket':
            return jsonify({"error": "The specified bucket does not exist."}), 404
        else:
            return jsonify({"error": f"Unexpected AWS error: {e.response['Error']['Message']}"}), 500

    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {str(e)}"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
