#!/bin/bash
#__auther__ = Hu
ip1=192.168.4.100
ip2=192.168.4.200
proxy='ssh root@192.168.4.5'
web1='root@192.168.4.100'
web2='root@192.168.4.200'
net1='/etc/sysconfig/network-scripts/ifcfg-eth0:0'
net2='/etc/sysconfig/network-scripts/ifcfg-lo:0'
#代理服务器的一些配置（配置VIP）
$proxy "cp /etc/sysconfig/network-scripts/ifcfg-eth0{,:0}"
$proxy "sed -i '/UUID/d' ${net1}"
$proxy "sed -i '/NAME/s/eth0/eth0:0/' ${net1}"
$proxy "sed -i '/DEVICE/s/eth0/eth0:0/' ${net1}"
$proxy "sed -i '/IPADDR/s/=.*/=192.168.4.15/' ${net1}"
$proxy "systemctl restart network"
$proxy "rpm -q ipvsadm > /dev/null || yum -y install ipvsadm > /dev/null"
$proxy "ipvsadm -A -t 192.168.4.15:80 -s wrr"
for i in $ip{1..2}
do
  $proxy "ipvsadm -a -t 192.168.4.15:80 -r ${i}:80"
done
#客户端的一些配置(配置VIP),为了防止地址冲突，我把VIP设在了回环地址上
for i in $web{1..2}
do
  ssh $i "\cp /etc/sysconfig/network-scripts/ifcfg-lo{,:0}"
  ssh $i "sed -i '/DEVICE/s/lo/lo:0/' $net2"
  ssh $i "sed -i '/IPADDR/s/=.*/=192.168.4.15/' $net2"
  ssh $i "sed -i '/NETWORK/s/=.*/=192.168.4.15/' $net2"
  ssh $i "sed -i '/NETMASK/s/=.*/=255.255.255.255/' $net2"
  ssh $i "sed -i '/BROADCAST/s/=.*/=192.168.4.15/' $net2"
  ssh $i "sed -i '/NAME/s/=.*/=lo:0/' $net2"
#当有arp广播问谁是$i时，本机忽略该ARP广播，不做任何回应
#本机不要向外宣告自己的lo回环地址是$i
  ssh $i "echo 'net.ipv4.conf.all.arp_ignore = 1' >> /etc/sysctl.conf"
  ssh $i "echo 'net.ipv4.conf.lo.arp_ignore = 1' >> /etc/sysctl.conf"
  ssh $i "echo 'net.ipv4.conf.lo.arp_announce = 2' >> /etc/sysctl.conf"
  ssh $i "echo 'net.ipv4.conf.all.arp_announce = 2' >> /etc/sysctl.conf"
  ssh $i "sysctl -p > /dev/null"
  ssh $i "systemctl restart network"
  if [ $? -ne 0 ];then
     ssh $i "systemctl stop NetworkManager"
     ssh $i "systemctl restart network"
  fi
  ssh $i "systemctl stop firewalld &> /dev/null"
  ssh $i "setenforce 0 &> /dev/null"
done
