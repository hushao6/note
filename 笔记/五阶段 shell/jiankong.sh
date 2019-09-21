#!/bin/bash
cpu=`uptime |  awk '{print $NF}'`
net_in=`ifconfig eth0 | awk '/RX p/{print $5,$6,$7}'`
net_out=`ifconfig eth0 | awk '/TX p/{print $5,$6,$7}'`
mem=`free -h | awk '/^M/{print $4}'`
disk=`df -h | awk '/\/$/{print $4}'`
user=`cat  /etc/passwd | wc -l`
login=`who | wc -l`
process=`ps aux | wc -l`
soft=`rpm -qa | wc -l`
echo -e "\033[32m当前主机监控信息\033[0m"
echo "当前CPU15分钟的负载情况是: $cpu"
echo "当前网卡接收流量为: $net_in"
echo "当前网卡发送流量为: $net_out"
echo "当前内存剩余容量为: $mem"
echo "当前磁盘剩余容量为: $disk"
echo "当前登录账号数量为: $user"
echo "当前登录账号数量为: $login"
echo "当前计算机开启的进程数量为: $process" 
echo "当前本机安装的软件包数量为: $soft"
sleep 3
