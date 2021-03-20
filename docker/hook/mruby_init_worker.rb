if ENV["REDIS_URL"].nil?
    p "mruby_init_worker: failed to connect to redis. ENV['REDIS_URL'] is nil."
end

if ENV["DATABASE_URL"].nil?
    p "mruby_init_worker: failed to connect to redis. ENV['DATABASE_URL'] is nil."
end

redis_url = ENV["REDIS_URL"]
redis_host, redis_port = redis_url[/^redis?:\/\/(.+)/, 1].split(":")
redis = Redis.new redis_host, redis_port.to_i

if redis != nil then
	Userdata.new("redis_#{Process.pid}").redis_connection = redis
end
