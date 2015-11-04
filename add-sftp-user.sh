#!/bin/bash
#建立USER並且加入至sftpuser群組，強迫使用者進入chroot模式
#家目錄在/sftp/%u/incoming下面
#注意1 /sftp/%u 權限要是root:root 755，/sftp/%u/incoming 權限要是 _username:sftpusers 755
#注意2 要用root執行
#2015.10.016 by Eason

export USERHOME=/sftp/$1
export INCOMING="$USERHOME"/incoming

useradd -g sftpusers -d /incoming -s /sbin/nologin $1
passwd $1 --stdin <<< "$2"
mkdir "$USERHOME"
chmod 755 "$USERHOME"

mkdir "$INCOMING"
chown $1:sftpusers "$INCOMING"
chmod 755 "$INCOMING"
