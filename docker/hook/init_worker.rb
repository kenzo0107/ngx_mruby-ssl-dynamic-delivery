class RedisClient
    def initialize
        if ENV["REDIS_HOST"].nil?
            p "mruby_init_worker: failed to connect to redis. ENV['REDIS_HOST'] is nil."
            Nginx.return Nginx::HTTP_NOT_FOUND
        end
        @redis_host = ENV["REDIS_HOST"]
    end

    def connect
        redis = Redis.new @redis_host, 6379
    end

    def set_redis_connection_to_user_data
        redis = connect
        Userdata.new("redis_#{Process.pid}").redis_connection = redis unless redis.nil?
    end

    def close
        redis = Userdata.new("redis_#{Process.pid}").redis_connection
        redis.close unless redis.nil?
    end
end

Userdata.new("redis_#{Process.pid}").client = RedisClient.new
Userdata.new("redis_#{Process.pid}").client.set_redis_connection_to_user_data
