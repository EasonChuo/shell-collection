#!/bin/sh
#更新主機內的apache版本
#主要是因應apache本身或者是Openssl發現弱點後所發布的新版本做更新
#2015.09.02 by Eason

mkdir /usr/src
cd /usr/src
rm -f httpd-$1*
echo  "Downloading apache-$1 ... "
wget http://ftp.tc.edu.tw/pub/Apache/httpd/httpd-$1.tar.gz

if [ -f httpd-$1.tar.gz ]; then
    echo "Finish."
else
    echo "File not found, please check if apache version is corrent."
    exit 1
fi

tar -zxf httpd-$1.tar.gz
cp /apshare/ap/build/config.nice /usr/src/httpd-$1/config.nice
cd httpd-$1/
./config.nice
make
make install

/apshare/ap/bin/apachectl -k graceful-stop
/apshare/ap/bin/apachectl -k start

echo "Finish!"                                                                                  1,1           All
