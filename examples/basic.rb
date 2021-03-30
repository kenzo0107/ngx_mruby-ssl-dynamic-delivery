Nginx.echo "mruby_content_handler basic.rb"
r = Nginx::Request.new
s = Nginx::Nginx.new
c = Nginx::Connection.new
Nginx.echo "hostname: " + r.hostname
Nginx.echo "path: " + s.path
Nginx.echo "hello world"
Nginx.echo "documento_root: #{s.document_root}"
Nginx.echo "path: #{s.path}"
Nginx.echo "remote ip: #{c.remote_ip}"
Nginx.echo "remote port: #{c.remote_port}"
Nginx.echo "user_agent: #{r.headers_in.user_agent}"
Nginx.echo "local ip: #{c.local_ip}"
Nginx.echo "local port: #{c.local_port}"

r.headers_in.all.keys.each do |k|
    Nginx.echo "#{k}: #{r.headers_in[k]}"
end
if /Mac/ =~ r.headers_in.user_agent
    Nginx.echo "your pc is mac"
end
