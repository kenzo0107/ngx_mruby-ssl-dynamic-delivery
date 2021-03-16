mysql = Userdata.new("mysql_#{Process.pid}").mysql_connection

# NOTE: redis へのコネクションが切断されている場合、接続する
if mysql == nil then
    Nginx.errlogger Nginx::LOG_INFO, "trying to connect to mysql"
    db_url = ENV["DATABASE_URL"]
    db_name = ENV["DB_NAME"]
    m = db_url.match(%r{mysql[0-9]?://(.+):(.+)?@([a-z0-9.-]+)/?(.+)?})
    db_user = m[1]
    db_pass = m[2]
    db_host = m[3]
    mysql = MySQL::Database.new(db_host, db_user, db_pass, db_name)

    if mysql != nil then
        Userdata.new("mysql_#{Process.pid}").mysql_connection = mysql
    end
end

mysql.execute('select * from certs') do |row, fields|
    puts fields # ["id", "domain", "ssl_crt_key", "crt", ...]
    puts row # [1, "localhost", "-----BEGIN RSA PRIVATE KEY-----...", "-----BEGIN CERTIFICATE-----...", ...]
end
