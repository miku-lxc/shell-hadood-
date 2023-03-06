#!/bin/bash
#       PATH='$JAVA_HOME/bin:$PATH' #注意不能使用cat配EOF追加 会让全局变量PATH生效 有全局变量都不能用
#自动创建jdk
mkdir /app
tar -xvf /opt/jdk-8u171-linux-x64.tar.gz -C /app/ 
cd /app
#上述命令可自行修改 仅作为educode平台的要求目录
ls -l

cat >>/etc/profile <<EOF
JAVA_HOME=/app/jdk1.8.0_171
EOF
path1='CLASSPATH=.:$JAVA_HOME/lib/tools.jar'
path2='PATH=$JAVA_HOME/bin:$PATH' #使用单引号让命令生效
printf "%s\n%s\n" $path1 $path2 >>/etc/profile
echo 'export JAVA_HOME CLASSPATH PATH' >>/etc/profile
# 上面的顺序一定要对

source /etc/profile
java -version



#mkdir -p ~/usr/hadoop
#mkdir -p ~/usr/hadoop/{tmp,hdfs,hdfs/{data,name}}
