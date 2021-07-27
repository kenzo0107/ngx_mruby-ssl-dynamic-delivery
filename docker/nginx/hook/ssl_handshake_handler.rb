# frozen_string_literal: true

# SSL ハンドシェイク制御
class SslHandshakeHandler
  def initialize(ssl, redis, dynamodb)
    @ssl = ssl
    @redis = redis
    @dynamodb = dynamodb
  end

  def subdomain_default_domain?
    # NOTE: サブドメインのレベル1を削除しデフォルトドメインと一致するか判定する
    # ex. aaa.example.com は example.com のサブドメインなので true となる
    d = @ssl.servername.split('.')
    d.delete_at(0)
    d = d.join('.')
    d.eql?(ENV['DEFAULT_DOMAIN'])
  end

  def crt_and_key
    domain = @ssl.servername

    # NOTE: デフォルトドメインのサブドメインである場合、
    #       デフォルトドメインのワイルドカード CRT, Key 情報を取得する
    domain = '*.' << ENV['DEFAULT_DOMAIN'] if subdomain_default_domain?

    certs(domain)
  end

  private

  def certs(domain)
    # Redis から取得できる場合、その値を返す
    crt, key = @redis.hmget domain, 'crt', 'key'
    return [crt, key] unless crt.nil? || key.nil?

    # Redis から取得できない場合、 DynamoDB から取得する
    crt, key = item_from_dynamodb(domain)

    # Redis にデータを登録し、以降、Redis のキャッシュを利用し高速化する
    @redis.hmset domain, 'crt', crt, 'key', key unless crt.nil? || key.nil?
    [crt, key]
  rescue StandardError => e
    Nginx::SSL.errlogger Nginx::LOG_NOTICE, '[certs] ' << e.message
    item_from_dynamodb(domain)
  end

  def item_from_dynamodb(domain)
    item = @dynamodb.item_by_domain(domain)

    # ドメインに紐づくデータが DynamoDB に登録されていない場合は nil を返す
    return [nil, nil] if item.nil?

    # DynamoDB に指摘キーが存在する場合、その値を返す
    return [item['crt'], item['key']] if item.key?('crt') && item.key?('key')

    [nil, nil]
  end
end

if ['test'].include?(ENV['ENVIRONMENT']) && Object.const_defined?(:MTest)
  # Nginx ダミークラス
  class Nginx
    LOG_NOTICE = 'notice'

    # Nginx::Request のダミークラス
    class SSL
      attr_accessor :servername

      def initialize
        @servername = nil
      end

      class << self
        def errlogger(log_level, msg); end
      end
    end
  end

  # DynamoDB のダミークラス
  class DynamoDB
    # NOTE: DynamoDB から証明書情報取得
    def item_by_domain(domain)
      req = HTTP::Request.new
      req.method = 'POST'
      req.body = JSON.stringify(domain: domain)
      req.headers['Content-Type'] = 'application/json'
      res = Curl.new.send(ENV['CERTS_URL'], req)
      body = JSON.parse(res.body)
      return {} if body.empty?

      body['Item']
    end
  end

  # テスト - SSL 証明書配信
  class TestSslHandshakeHandler < MTest::Unit::TestCase
    def setup
      @redis = Redis.new ENV['REDIS_HOST'], 6379
      @dynamodb = DynamoDB.new
    end

    def test_subdomain_default_domain
      # aaa.localhost はサブドメインなので
      # subdomain_default_domain? が true を返す
      s = Nginx::SSL.new
      s.servername = 'aaa.localhost'

      h = SslHandshakeHandler.new(s, @redis, @dynamodb)
      assert_equal(h.subdomain_default_domain?, true)
    end

    def test_subdomain_original_domain
      # 独自ドメインはサブドメインでないので
      # subdomain_default_domain? が false を返す
      s = Nginx::SSL.new
      s.servername = 'foo.example.com'

      h = SslHandshakeHandler.new(s, @redis, @dynamodb)
      assert_equal(h.subdomain_default_domain?, false)
    end

    def test_crt_and_key
      # Redis, DynamoDB それぞれの証明書情報が取得でき、一致している
      s = Nginx::SSL.new
      s.servername = 'aaa.localhost'

      # GitHub Actions テスト前は Redis データが消去されている前提
      # 初回は DynamoDB からデータ取得
      d = SslHandshakeHandler.new(s, @redis, @dynamodb)
      dynamodb_crt, dynamodb_key = d.crt_and_key

      # 次回は Redis からデータ取得
      r = SslHandshakeHandler.new(s, @redis, @dynamodb)
      redis_crt, redis_key = r.crt_and_key

      assert_equal(redis_crt, dynamodb_crt)
      assert_equal(redis_key, dynamodb_key)
    end
  end

  MTest::Unit.new.run
else
  ssl = Nginx::SSL.new
  redis = Userdata.new("redis_#{Process.pid}").redis_connection
  dynamodb = Userdata.new("dynamodb_#{Process.pid}").dynamodb
  crt, key = SslHandshakeHandler.new(ssl, redis, dynamodb).crt_and_key
  ssl.certificate_data = crt
  ssl.certificate_key_data = key
end
