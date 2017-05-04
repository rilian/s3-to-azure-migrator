S3ID = ENV.fetch('S3ID')
S3KEY = ENV.fetch('S3KEY')
S3BUCKET = ENV.fetch('S3BUCKET')

require 'aws/s3'
include AWS::S3
AWS::S3::Base.establish_connection!(
  :access_key_id     => S3ID,
  :secret_access_key => S3KEY
)

bucket = AWS::S3::Bucket.find(S3BUCKET)
puts "\nS3 bucket has #{bucket.size} files:"

bucket_dir = "/tmp/s3-to-azure-migrator/#{S3BUCKET}"
puts "\nCreating folder to store S3 files on: #{bucket_dir}"
require 'fileutils'
FileUtils.mkdir_p bucket_dir

errors = []

bucket.each_with_index do |obj, index|
  next if obj.path[-1] == '/'

  local_path = File.join(bucket_dir, obj.key)

  file_dir = local_path.rpartition('/').first
  puts "\n[#{index + 1}/#{bucket.size}] Creating folder: #{file_dir}"
  FileUtils.mkdir_p file_dir

  puts "Downloading file #{obj.path} into #{local_path}"
  File.open(local_path, 'w') do |f|
    begin
      f.write(obj.value)
    rescue Exception => e
      puts "ERROR: #{e.message}"
      errors << { key: obj.key }
    end
  end

  puts "success, #{File.size local_path} bytes"
end

if errors.size > 0
  puts "\n#{errors.size} files were not downloaded"
  errors.each do |obj|
    puts obj.inspect
  end
end
