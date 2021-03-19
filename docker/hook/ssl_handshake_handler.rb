redis = Userdata.new("redis_#{Process.pid}").redis_connection

# NOTE: redis へのコネクションが切断されている場合、接続する
if redis == nil then
    Nginx.errlogger Nginx::LOG_INFO, "trying to connect to redis"
    redis_url = ENV["REDIS_URL"]
    redis_host, redis_port = redis_url[/^redis?:\/\/(.+)/, 1].split(":")
    redis = Redis.new redis_host, redis_port.to_i
    Userdata.new("redis_#{Process.pid}").redis_connection = redis
end

ssl = Nginx::SSL.new
Nginx::SSL.errlogger Nginx::LOG_NOTICE, "Servername is #{ssl.servername}"
crt, key = redis.hmget ssl.servername, 'crt', 'key'

if crt.empty? || key.empty? then
    # TODO: redis に登録されていない場合、DB を参照する
    #       DB に登録されていない場合は、エラー発生させ、処理を停止させる

    Nginx.return Nginx::HTTP_NOT_FOUND
end

ssl.certificate_data = crt
ssl.certificate_key_data = key
