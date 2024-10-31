The following is a step by step of what I did to set up the s3 storage

1. Create an S3 Bucket
    -In your AWS Console, navigate to S3 and create a new bucket for production storage.
    -Enable versioning and server-side encryption to protect data.
    Configure Access Control

2. Set up an IAM user with specific permissions to access the S3 bucket.
   - Attached policies to this user I allowed the IAM full access to my S3 bucket
   - Generate access keys (Access Key ID and Secret Access Key) for this IAM user.
     Add AWS Credentials to Rails Application in the .ENV file

3. Store the IAM user’s access keys in a secure place. For example, add them to environment variables or use Rails credentials.
   - Set up your config/storage.yml file to use S3 in production mode, referencing these credentials.

4. Update Production Environment Config
   - Open config/environments/production.rb and set the storage service to :amazon by adding:
        - config.active_storage.service = :amazon

5. Go to the S3 bucket settings and create a bucket policy to control public access.
   - Configure this policy to allow access only to the IAM user you created, enhancing security.
6. Set Up CORS Configuration
   - In your S3 bucket settings, add a CORS configuration to allow cross-origin requests for uploading and retrieving files.