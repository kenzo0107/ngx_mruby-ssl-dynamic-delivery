#!/bin/sh
readonly DIR=certs

NAME=$1

openssl genrsa -out ${DIR}/${NAME}.key 4096
openssl req -new -key ${DIR}/${NAME}.key -out ${DIR}/${NAME}.csr -subj "/CN=*.${NAME}"
openssl x509 -req -in ${DIR}/${NAME}.csr -days 36500 -signkey ${DIR}/${NAME}.key > ${DIR}/${NAME}.crt
