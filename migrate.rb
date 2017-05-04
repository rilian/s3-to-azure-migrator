require 'bundler'

Bundler.require(:default)

require 'aws/s3'

S3ID = ENV.fetch('S3ID')
S3KEY = ENV.fetch('S3KEY')
S3BUCKET = ENV.fetch('S3BUCKET')

include AWS::S3
AWS::S3::Base.establish_connection!(
  :access_key_id     => S3ID,
  :secret_access_key => S3KEY
)

bucket = AWS::S3::Bucket.find(S3BUCKET)
puts bucket.inspect

puts bucket.size

