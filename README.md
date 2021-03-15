## 目的
ngx_mruby でローカル環境で動的証明書配信を試験する。

以下論文の p4 にある設定例を参考に検証する。
[高集積マルチテナントWebサーバの大規模証明書管理](https://rand.pepabo.com/papers/iot37-proceeding-matsumotory.pdf)


## 前提

* localhost ドメインで docker/certs/ 以下に key, crt ファイルを発行済み

## 設定例1. 証明書ファイルを動的読み込み

```
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
```

証明書ファイルが増えると起動が遅くなるデメリットがある為、以下「設定例2」を検証する。

## 設定例2. KVS ベースで証明書を動的読み込み

```
server {
    listen 443 ssl;
    server_name _;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_certificate /path/to/dummy.crt;
    ssl_certificate_key /path/to/dummy.key;
    mruby_ssl_handshake_handler_code ’
        ssl = Nginx::SSL.new
        host = ssl.servername
        redis = Redis.new "127.0.0.1", 6379
        ssl.certificate_data = redis["#{host}.crt"]
        ssl.certificate_key_data = redis["#{host}.key"]
    ’;
}
```

## Findings

* mruby_init_worker で `Nginx.echo` は使用できない。
* `Nginx.echo` は 200 OK を返す。
  * ブラウザでアクセスすると `Nginx.echo` で出力する文字列が表示されていることがわかる。
  * その後、 500 error がある場合でも 200 OK を一旦返してしまう。
* デバッグ等で出力したい場合は logger を使おう！
  - `Nginx.errlogger Nginx::LOG_INFO, "foo"`
  - ssl_handler 内では `Nginx::SSL.errlogger Nginx::LOG_NOTICE, "foo"`

