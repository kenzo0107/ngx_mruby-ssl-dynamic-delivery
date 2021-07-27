# frozen_string_literal: true

# SSL ハンドシェイク制御
class SslHandshakeHandler
  def initialize
    @ssl = Nginx::SSL.new
    @domain = @ssl.servername
  end

  def get_crt_and_key(domain)
    redis = Userdata.new("redis_#{Process.pid}").redis_connection
    redis.hmget domain, 'crt', 'key'
  end

  def subdomain_default_domain?
    d = @domain.split('.')
    d.delete_at(0)
    d = d.join('.')
    d.eql?(ENV['DEFAULT_DOMAIN'])
  end

  def set_crt_and_key
    domain = @domain

    # NOTE: デフォルトドメインのサブドメインである場合、
    #       デフォルトドメインのワイルドカード CRT, Key 情報を取得する
    domain = ENV['DEFAULT_DOMAIN'] if subdomain_default_domain?
    crt, key = get_crt_and_key(domain)
    if crt.nil? || key.nil?
      m = "crt, key of servername #{domain} are invalid."
      Nginx::SSL.errlogger Nginx::LOG_NOTICE, m
      Nginx.return Nginx::HTTP_NOT_FOUND
    end

    @ssl.certificate_data = crt
    @ssl.certificate_key_data = key
  end
end

SslHandshakeHandler.new.set_crt_and_key
