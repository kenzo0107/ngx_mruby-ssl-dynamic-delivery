# frozen_string_literal: true

if ENV['REDIS_HOST'].nil?
  m = 'mruby_init_worker: failed to connect to redis. ENV[REDIS_HOST] is nil.'
  Nginx.errlogger Nginx::LOG_NOTICE, m
  Nginx.return Nginx::HTTP_NOT_FOUND
end

begin
  redis = Redis.new ENV['REDIS_HOST'], 6379
rescue StandardError => e
  p e.message
end

# スクリプト間のデータ渡しは Userdata を利用する
Userdata.new("redis_#{Process.pid}").redis_connection = redis unless redis.nil?
