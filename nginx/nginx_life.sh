#!/bin/bash
#该脚本负责nginx的生命周期
#centos6的nginx启动脚本
#/etc/init.d/

#默认nginx启动路径/usr/local/nginx
nginx=/usr/local/nginx/sbin/nginx
pid=/usr/local/nginx/logs/nginx.pid

case $1 in

start)
	if [[ -f $pid ]];then
		echo -e "\e[91mNginx is already running...\e[0m"
		exit 10
	else
		$nginx && echo -e "\e[32mNginx is already running...\e[0m"
	fi
	;;
stop)
	if [[ ! -f $pid ]];then
		echo -e "\e[91mNginx is already stopped...\e[0m"
		exit 20
	else
		$nginx -s stop && echo -e "\e[32mNginx is already stopped...\e[0m"
	fi
	;;
restart)
	if [[ ! -f $pid ]];then
		echo -e "\e[91mNginx is already stopped...\e[0m"
		echo -e "\e[91mPlease to run nginx first\e[0m"
		exit 30
	else
		$nginx -s stop  && echo -e "\e[32mNginx is already stopped...\e[0m"
	fi
	$nginx && echo -e "\e[32mNginx is already running...\e[0m"
	;;
status)
	if [[ -f $pid ]];then
		echo -e "\e[32mNginx is already running...\e[0m"
	else
		echo -e "\e[32mNginx is already stopped...\e[0m"
	fi
	;;
reload)
	if [[ ! -f $pid ]];then
		echo -e "\e[91mNginx is already stopped...\e[0m"
		exit 40
	else
		$nginx -s reload && echo -e "\e[32mReload configure done.\e[0m"
	fi
	;;
*)
	echo "Usage:$0 {start|stop|restart|status|reload}"
	;;
esac

