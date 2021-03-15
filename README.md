## 目的
ngx_mruby でローカル環境で動的証明書配信を試験する。

以下論文の p4 にある設定例を参考に検証する。

[高集積マルチテナントWebサーバの大規模証明書管理](https://rand.pepabo.com/papers/iot37-proceeding-matsumotory.pdf)


## 前提

* localhost ドメインで docker/certs/ 以下に key, crt ファイルを発行済み

## 設定例1. 証明書ファイルを動的読み込み

```
http {
    server {
        listen 443 ssl;
        server_name _;
        ssl_certificate /etc/ssl/certs/dummy.crt;
        ssl_certificate_key /etc/ssl/certs/dummy.key;

        mruby_ssl_handshake_handler_code '
            ssl = Nginx::SSL.new
            host = ssl.servername
            ssl.certificate = "/etc/ssl/certs/#{host}.crt"
            ssl.certificate_key = "/etc/ssl/certs/#{host}.key"
        ';
    }
}
```

証明書ファイルが増えると起動が遅くなるデメリットがある為、
以下「設定例2. KV ベースで証明書を動的読み込み」を検証する。

## 設定例2. KVS ベースで証明書を動的読み込み

```
env REDIS_HOST;

http {
  server {
      listen 443 ssl;
      server_name _;
      ssl_certificate /path/to/dummy.crt;
      ssl_certificate_key /path/to/dummy.key;
      mruby_ssl_handshake_handler_code '
          ssl = Nginx::SSL.new
          host = ssl.servername
          redis = Redis.new ENV["REDIS_HOST"], 6379
          crt, key = redis.hmget host, "crt", "key"
          ssl.certificate_data = crt
          ssl.certificate_key_data = key
      ';
  }
}
```

* Redis にデータ登録

```
$ docker-compose exec redis \
  redis-cli hmset localhost crt "$(cat docker/certs/localhost.crt)" \
  key "$(cat docker/certs/localhost.key)"
$ docker-compose exec redis redis-cli hmget localhost crt key
```

## Findings

* mruby_init_worker で `Nginx.echo` は使用できない。
* `Nginx.echo` は 200 OK を返す。
  * ブラウザでアクセスすると `Nginx.echo` で出力する文字列が表示されていることがわかる。
  * その後、 500 error がある場合でも 200 OK を一旦返してしまう。
* デバッグ等で出力したい場合は logger を使おう！
  - `Nginx.errlogger Nginx::LOG_INFO, "foo"`
  - ssl_handler 内では `Nginx::SSL.errlogger Nginx::LOG_NOTICE, "foo"`
