[![build test](https://github.com/kenzo0107/ngx_mruby-ssl-dynamic-delivery/actions/workflows/build_test.yml/badge.svg)](https://github.com/kenzo0107/ngx_mruby-ssl-dynamic-delivery/actions/workflows/build_test.yml) [![Lint](https://github.com/kenzo0107/ngx_mruby-ssl-dynamic-delivery/actions/workflows/lint.yml/badge.svg)](https://github.com/kenzo0107/ngx_mruby-ssl-dynamic-delivery/actions/workflows/lint.yml)

## 本リポジトリの目的
ngx_mruby でローカル環境で動的証明書配信を試験する。

以下論文の p4 にある設定例を参考に検証する。

[高集積マルチテナントWebサーバの大規模証明書管理](https://rand.pepabo.com/papers/iot37-proceeding-matsumotory.pdf)


## 開発環境の構築

### 1. 環境に必要なツールのインストール

- [dip](https://github.com/bibendi/dip)

### 2. プロビジョニング

```console
dip provision
```

開発で使用する `*.localhost` ワイルドカード証明書の localhost.crt, localhost.key を作成し redis に登録します。

### 3. /etc/hosts 設定

```console
echo "127.0.0.1 aaa.localhost bbb.localhost" | sudo tee -a /etc/hosts
```

aaa.localhost, bbb.localhost を 127.0.0.1 に向ける。

### 4. serverの起動

```console
docker-compose up -d
```

## テスト実行

```console
dip test
```
