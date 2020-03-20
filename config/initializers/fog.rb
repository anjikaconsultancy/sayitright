# # Global storage object, we need to check ENV is loaded or this fails and asset compilation fails.
# if ENV['S3_ACCESS_KEY_ID'].present?
#   FogStorage = Fog::Storage.new({:provider => 'AWS',:aws_access_key_id => ENV['S3_ACCESS_KEY_ID'], :aws_secret_access_key  => ENV['S3_SECRET_ACCESS_KEY']})
# end