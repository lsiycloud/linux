#!/bin/bash
#该脚本为非交互式，负责监控http服务的运行状态

#检测的ip地址
#ip=
ip=192.168.182.211


#检测的端口
#port=80
port=80


#检测的网页
#website=
website=a.html


url=http://$ip:$port/$website
date=$(date +"%Y-%m-%d %H:%M:%S")
mail_to="root@localhost"
mail_subject="Http_Warning"

curl_http() {
url_hash=$(curl -s http://$ip:$port/$website | md5sum | awk '{print $1}')

#需要获取网页的md5值
#source_hash
source_hash="884be9fd7fe83bd82dbc0fc610ab3a96"
}


status_code=$(curl -m 3 -s -o /dev/null -w %{http_code} $url)


#检测httpd服务端口状态
nmap -n -sS -p80 $ip | grep -q "^80/tcp open"
if [ $? -eq 0 ];then
        echo "http server is running on $ip" | mail -s http_status_OK $mail_to
else
        echo "http server is stopped on $ip" | mail -s http_status_Error $mail_to
fi

#检测网页运行的状态
if [ $status_code -ne 200 ];then
        mail -s $mail_subject $mail_to <<-EOF
        检测时间: $date
        $url 页面异常
        状态码为: $status_code
        请尽快排查
        EOF
else
        cat >> /var/log/http_check.log <<-EOF
        $date "$url 页面访问正常"
        EOF
fi

#检测网页是否被篡改
curl_http
if [ "$url_hash" != "$source_hash" ];then
        mail -s $mail_subject $mail_to <<-EOF
        检测时间：$date
        数据完整校验失败,$url,页面被篡改
        请尽快排查
        EOF
else
        cat >> /var/log/http_check.log <<-EOF
        $date  "$url,数据完整性校验正常"
        EOF
fi
echo -e "\033[33m正在检查,请稍等...\033[0m"             
sleep 5
echo -e "\033[42m检查完毕\033[0m"
