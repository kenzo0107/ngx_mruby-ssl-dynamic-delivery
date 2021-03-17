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

db_url = ENV["DATABASE_URL"]
db_name = ENV["DB_NAME"]
# NOTE: DATABASE_URL = mysql2://user:password@host である想定
m = db_url.match(%r{mysql[0-9]?://(.+):(.+)?@([a-z0-9.-]+)/?(.+)?})
db_user = m[1]
db_pass = m[2]
db_pass = "" if db_pass.nil?
db_host = m[3]

mysql = MySQL::Database.new(db_host, db_user, db_pass, db_name)

if mysql != nil then
	Userdata.new("mysql_#{Process.pid}").mysql_connection = mysql
end
