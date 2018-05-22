Qiniu.establish_connection! access_key: ENV["qiniu_access_key"],
                            secret_key: ENV["qiniu_secret_key"]

Qiniu::DOMAIN = ENV["qiniu_domain"]
Qiniu::BUCKET = ENV["qiniu_bucket"]