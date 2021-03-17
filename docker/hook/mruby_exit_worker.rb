redis = Userdata.new("redis_#{Process.pid}").redis_connection
if redis != nil then
    Userdata.new("redis_#{Process.pid}").redis_connection.close
end

mysql = Userdata.new("mysql_#{Process.pid}").mysql_connection
if mysql != nil then
    Userdata.new("mysql_#{Process.pid}").mysql_connection.close
end
