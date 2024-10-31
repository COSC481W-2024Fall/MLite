require 'aws-sdk-s3' # Ensure the AWS SDK for S3 is required

Aws.config.update({
                    region: 'us-east-1',
                    credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']) # Accessing from .env
                  })

S3_BUCKET = Aws::S3::Resource.new.bucket('my-production-datasets')