#!/bin/sh
#安裝nginx指令包
#2016.02.22 init by Eason
yum update -y
yum install gcc* openssl-deve -y
yum install pcre* -y

mkdir /usr/src
cd /usr/src

#下載指定版本的nginx
export nginxVersion="1.10.3" 
wget http://nginx.org/download/nginx-$nginxVersion.tar.gz 
tar -xzf nginx-$nginxVersion.tar.gz 
ln -sf nginx-$nginxVersion nginx

#下載nginx-sticky-module，此版號為1.2.5
wget https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/master.tar.gz
tar -zxf master.tar.gz
mv nginx-goodies-nginx-sticky-module-ng-08a395c66e42 nginx-sticky-module-ng

#編譯nginx
cd nginx 
./configure \
 --user=nginx \
 --group=nginx \
 --prefix=/etc/nginx \
 --sbin-path=/usr/sbin/nginx \
 --conf-path=/etc/nginx/nginx.conf \
 --pid-path=/var/run/nginx.pid \
 --lock-path=/var/run/nginx.lock \
 --error-log-path=/etc/nginx/logs/error.log \
 --http-log-path=/etc/nginx/logs/access.log \
 --with-http_gzip_static_module \
 --with-http_stub_status_module \
 --with-http_ssl_module \
 --with-pcre \
 --with-file-aio \
 --with-http_realip_module \
 --without-http_scgi_module \
 --without-http_uwsgi_module \
 --without-http_fastcgi_module \
 --add-module=/usr/src/nginx-sticky-module-ng \
 --with-ipv6
 
make
make install
useradd -r nginx
#建立log目錄
mkdir /etc/nginx/logs
chown nginx:nginx /etc/nginx/logs/

#下載服務設定檔
cd /etc/init.d
wget -O /etc/init.d/nginx https://gist.github.com/sairam/5892520/raw/b8195a71e944d46271c8a49f2717f70bcd04bf1a/etc-init.d-nginx

#賦予service檔案執行權限
chmod +x /etc/init.d/nginx

#啟動時自動執行
chkconfig --add nginx
chkconfig nginx on

echo "Finish!"
