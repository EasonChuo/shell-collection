#!/bin/bash
#檢查tomcat服務是否正常運作
#如果沒有正常運作可以執行特定指令
#auto detect tomcat is alive or not,
#and auto restart tomcat if it dead.
#2015.09.02 by Eason

tomcat=("http://1.1.1.1/", "http://1.1.1.2/")

for i in "${tomcat[@]}"
do

status=$(curl --connect-timeout 3 --write-out %{http_code} --silent --output /dev/null $i )

if [ "$status" = "200" ] ; then
  echo "$i is alive."
else
  echo "$i is dead."
  #run command when failed
fi

done
~
~
~
~
~
~
~
~
~
~
"/apshare/tomcat202/w1-detector.sh" 20L, 430C written                                                             11,34         All
