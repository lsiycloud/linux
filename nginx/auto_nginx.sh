#!/bin/bash
#安装nginx源码包
#version 1.0

decompression_package=$(echo ${package%.tar*})

#定义颜色属性
color_fail="echo -ne \\033[91m"
color_access="echo -ne \\033[32m"
color_normal="echo -e \\033[0m"

echo "Please enter the source code package to be installed: "
read  package

echo "Please enter the installation path: (default /usr/local/)"
read  path
path=${path:-/usr/local/}

#判断是否以管理员身份运行此脚本
if [[ $UID -ne 0 ]];then
	$color_fail
	echo -n "请以管理员身份运行此脚本"
	$color_normal
	exit 10
fi
#判断是否有nginx用户，没有则创建
if ! id nginx &> /dev/null;then
	useradd -s /sbin/nologin nginx
fi

#判断系统是否存在wget下载工具
#-c 开启断点续传功能
if rpm -q --quiet wget;then
	wget -c http://nginx.org/download/$package
else
	$color_fail
	echo -n "未找到wget，请安装该软件"
	$color_normal
	exit 15
fi
#判断是否找到正确的源码包
#在安装之前，先安装依赖包
if [[ ! -f $package ]];then
	$color_fail
	echo -n "未找到源码包"
	$color_normal
	exit 20
else
	yum -y install gcc pcre-devel openssl-devel &> /dev/null
	$color_success
	echo -n "需要几分钟编译安装源码包，请耐心等待"
	$color_nomal
	sleep 5
	tar -xf $package -C .
	cd $decompression_package
	./configure\
	--user=nginx\
	--group=nginx\
	--prefix=$path\
	--with-stream\
	--with-http_ssl_module\
	--with-http_stub_status_module
	make
	make install
fi

if [[ -x $path/sbin/nginx ]];then
	$color_access
	echo -n "nginx已安装完毕"
	$color_normal
fi


