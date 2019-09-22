#!/bin/bash
ip="192.168.4.10"
ipran="192.168.3.1-50"
read -p "请输入创建的vpn用户名(默认为tom)" remoteuser
read -p "请输入创建的vpn密码(默认为123456)" remoteuser
read -p "请输入软件绝对路径" pack
ssh root@${ip} "yum -y install ${pack} &> /dev/null"
if [ $? -eq 0  ];then
#服务器本地ip
  ssh root@${ip} "echo "localip ${ip}" >> /etc/pptpd.conf"
#分配至客户端的ip池
  ssh root@${ip} "echo "remoteip ${ipran}" >> /etc/pptpd.conf"
#设置dns服务器
#  ssh root@${ip} "echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd"
#修改账户配置文件
  ssh root@${ip} "echo '${remoteuser:-tom} * ${remotepass:-123456} * ' >> /etc/ppp/chap-secrets"
#开机路由转发功能
  ssh root@${ip} "echo "1" > /proc/sys/net/ipv4/ip_forward"
  ssh root@${ip} "systemctl restart pptpd"
else
  echo "安装包位置错误，或者已经安装"
fi
