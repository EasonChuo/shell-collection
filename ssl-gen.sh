#!/bin/sh
#自產SSL憑證
#2048 bit, 10年效期
#2016.04.13 init by Eason

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

cat server.crt > server.pem
cat server.key >> server.pem

openssl req -new -x509 -days 3650 -extensions v3_ca -keyout cakey.pem -out cacert.pem -nodes
cat cacert.pem  cakey.pem > cert.pem

openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -nodes -days 3650

