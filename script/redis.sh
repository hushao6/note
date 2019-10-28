#!/bin/bash
#这是一个一键部署redis的脚本,您只需要在网上把redis的tar包下载好即可
ip1=192.168.2.200
ip2=192.168.4.55
read -p "请输入本机redis的tar包的绝对路径" tar
##分解成tar包名字
tarname=${tar##*/}
#echo $tarname
#分解成tar解压完的目录名字
dirname=${tarname%.ta*}
#echo $dirname
for i in $ip1
do
    scp -r $tar root@$i:/tmp
#安装所需的环境
    ssh root@$i "rpm -q gcc || yum -y install gcc &>/dev/null"
    ssh root@$i "tar xf /tmp/${tarname} -C /tmp
				 cd /tmp/${dirname}
				 make && make install "
#内容
expect << EOF
spawn ssh $i
expect "#"  { send "/tmp/$dirname/utils/install_server.sh \r"}
expect "6379] " {send "\r"}
expect "/etc/redis/6379.conf] " {send "\r"}
expect "/var/log/redis_6379.log] " {send "\r"}
expect "/var/lib/redis/6379] " {send "\r"}
expect "/usr/local/bin/redis-server] " {send "\r"}
expect "abort." {send "\r"}
expect "#"          { send "exit\r" }
expect "#"          { send "exit\r" }
EOF
done
