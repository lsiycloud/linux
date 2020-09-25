#!/bin/bash
#该脚本为交互式，负责监控http服务的运行状态

date=$(date +"%Y-%m-%d %H:%M:%S")
mail_to="root@localhost"
mail_subject="Http_Warning"

curl_http() {
url_hash=$(curl -s http://$ip:$port/$website | md5sum | awk '{print $1}')
#需要获取网页的md5值
source_hash="884be9fd7fe83bd82dbc0fc610ab3a96"
}

echo -e "请输入检查目标主机的ip: "
read ip

echo -e "请输入检查网页的端口号: (default: 80)"
read port
port=${port:-80}

echo -e "请输入检查的页面: "
read website


status_code=$(curl -m 3 -s -o /dev/null -w %{http_code} http://$ip:$port/$website)

echo -e "\e[33m----------------------
1.ping
2.curl
3.md5
4.exit
----------------------\e[0m"
read -p "请输入要检查的编号（1～3）" num

case $num in

1)

        if [ ! -z $ip ];then
                nmap -n -sS -p80 $ip | grep -q "^80/tcp open"
        else
                echo -e "\e[91m请输入正确ip\e[0m"
                exit 10
        fi

        if [ $? -eq 0 ];then
                echo "http server is running on $ip" | mail -s http_status_OK $mail_to
        else
                echo "http server is stopped on $ip" | mail -s http_status_Error $mail_to
        fi
        ;;
2)
        if [ -z $ip ];then
                echo -e "\e[91m请输入正确ip\e[0m"
                exit 20
        fi

        if [ $status_code -ne 200 ];then
                mail -s $mail_subject $mail_to <<-EOF
                检测时间: $date
                http://$ip:$port/$website 页面异常
                状态码为: $status_code
                请尽快排查
                EOF
        else
		cat >> /var/log/http_check.log <<-EOF
                $date "http://$ip:$port/$website 页面访问正常"
                EOF
        fi
        ;;
3)
        if [ -z $ip ];then
                echo -e "\e[91m请输入正确ip\e[0m"
                exit 30
        fi

        curl_http
        if [ "$url_hash" != "$source_hash" ];then
                mail -s $mail_subject $mail_to <<-EOF
                检测时间：$date
                数据完整校验失败,http://$ip:$port/$website,页面被篡改
                请尽快排查
                EOF
        else
                cat >> /var/log/http_check.log <<-EOF
                $date  "http://$ip:$port/$website,数据完整性校验正常"
                EOF
        fi
        ;;
4)
        echo -e "\033[32mBye-bye\033[0m"
        exit 40
        ;;
*)
        echo -e "\e[91m请正确输入编号: (1~3)\e[0m"
        ;;
esac
