#!/bin/sh
#更新主機內的openssl版本
#主要是因應Openssl發現弱點後所發布的新版本做更新
#2015.09.02 init by Eason
#2015.09.02 加入安裝gcc相關工具的指令 by Eason
yum update
yum install dos2unix -y
yum install gcc* -y

mkdir /usr/src
cd /usr/src
wget http://www.openssl.org/source/openssl-1.0.1$1.tar.gz
tar -zxf openssl-1.0.1$1.tar.gz
cd openssl-1.0.1$1
./config --prefix=/usr --openssldir=/usr/local/openssl shared
make
make test
make install
cd /usr/src
rm -rf openssl-1.0.1$1.tar.gz
rm -rf openssl-1.0.1$1

openssl version
echo "Finish!"
