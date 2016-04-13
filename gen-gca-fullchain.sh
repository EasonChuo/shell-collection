#!/bin/sh
#將GCA簽發的憑證由cer格式轉為crt格式，並且合併GRCA根憑證
#合併完的憑證為一個完整憑證，可以讓所有瀏覽器受信任
#$1 為GCA網站下載回來的cer檔，不要輸入副檔名，shell會自己加
#2016.04.13 init by Eason

openssl x509 -inform DER -in $1.cer -out $1.crt
cat file/GRCA2.crt $1.crt > $1-fullchain.crt