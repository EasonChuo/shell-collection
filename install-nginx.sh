#!/bin/sh
#安裝nginx指令包
#2016.02.22 init by Eason
yum update -y
yum install gcc* openssl-devel -y
yum install pcre* -y
yum install patch -y
yum install git -y

mkdir /usr/src
cd /usr/src

#下載指定版本的nginx
export nginxVersion="1.18.0" 
wget http://nginx.org/download/nginx-$nginxVersion.tar.gz 
tar -xzf nginx-$nginxVersion.tar.gz 
ln -sf nginx-$nginxVersion nginx

#下載nginx-sticky-module，此版號為1.2.5
wget https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/master.tar.gz
tar -zxf master.tar.gz
mv nginx-goodies-nginx-sticky-module-ng-08a395c66e42 nginx-sticky-module-ng

#下載nginx-module-vts
git clone https://github.com/vozlt/nginx-module-vts.git
#下載nginx_upstream_check_module
git clone https://github.com/yaoweibin/nginx_upstream_check_module
#下載ip2location
git clone https://github.com/ip2location/ip2location-nginx
#下載nginx_cookie_flag_module
git clone https://github.com/AirisX/nginx_cookie_flag_module/
#下載IP2Location原始碼給nginx編譯用
#依實際需求引入IP2Location
git clone https://github.com/chrislim2888/IP2Location-C-Library
rsync -av IP2Location-C-Library/libIP2Location/ ip2location-nginx/

#更新nginx_upstream_check_module所需的patch
cd /usr/src/nginx-sticky-module-ng
patch -p0 < /usr/src/nginx_upstream_check_module/nginx-sticky-module.patch
cd /usr/src/nginx
patch -p1 < /usr/src/nginx_upstream_check_module/check_1.14.0+.patch

#編譯nginx
cd /usr/src/nginx 
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
 --add-module=/usr/src/nginx-module-vts \
 --add-module=/usr/src/nginx_upstream_check_module \
 --add-module=/usr/src/nginx_cookie_flag_module \
 --add-module=/usr/src/ip2location-nginx
 
make && make install
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
