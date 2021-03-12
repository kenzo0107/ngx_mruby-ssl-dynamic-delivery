## 目的
ngx_mruby でローカル環境で動的証明書配信を試験する。


## dummy crt 作成
```
openssl genrsa -out dummy.key 4096
openssl req -new -key dummy.key -out dummy.csr -subj "/CN=localhost"
openssl x509 -req -in dummy.csr -days 36500 -signkey dummy.key > dummy.crt
```

## DB にデータ登録

```
docker-compose exec db mysql < insert.sql
```
