#!/bin/bash
read -p '请输入需要修改的文件后缀名: ' c
read -p '请输入需要修改成什么样的文件后缀名: ' n
for i in `ls /opt/*.$c`
do
#利用去尾把原始文件名去掉
  a=${i%.*}
  mv $i $a.$n
done
