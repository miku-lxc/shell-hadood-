#!/bin/bash

#wget -cP /opt http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz

cd /opt/
tar -xvf hadoop-3.1.0.tar.gz -C /app
mv /app/hadoop-3.1.0/ /app/hadoop3.1  #这里的文件名一定要注意 在这里踩了很多坑
#设置免密登录
ssh-keygen -t rsa -P ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

cat >>/etc/ssh/sshd_config <<EOF
RSAAuthentication yes # 启用 RSA 认证
PubkeyAuthentication yes # 启用公钥私钥配对认证方式
AuthorizedKeysFile %h/.ssh/authorized_keys # 公钥文件路径
EOF

#service ssh restari #实训平台不需要 本地需要

#修改hadood的配置文件
cd /app/hadoop3.1/etc/hadoop/
echo 'export JAVA_HOME=/app/jdk1.8.0_171' >>hadoop-env.sh
echo 'export JAVA_HOME=/app/jdk1.8.0_171' >>yarn-env.sh

#核心配置组建 包括格式和字段的说明 主要添加三个默认的字段name和value 以及description
#以下字段均不能留默认的，在默认后面追加，直接优先去掉 选择用sed按范围去除
#使用nl -ba 文件 来查看编号去定删除范 sed使用如下 -ie.bak 做个备份也可以的 '15，$d'$ 代表结束

#去默认范围
sed -ie '16,$d' core-site.xml
sed -ie '16,$d' hdfs-site.xml
sed -ie '16,$d' mapred-site.xml
sed -ie '15,$d' yarn-site.xml

#进行追加输入
cat >>core-site.xml <<EOF
<configuration>  
     <property>  
        <name>fs.default.name</name>  
        <value>hdfs://localhost:9000</value>  
        <description>HDFS的URI，文件系统://namenode标识:端口号</description>  
    </property>  
    <property>  
        <name>hadoop.tmp.dir</name>  
        <value>/usr/hadoop/tmp</value>  
        <description>namenode上本地的hadoop临时文件夹</description>  
    </property>  
</configuration>  
EOF


cat >>hdfs-site.xml <<EOF
<configuration>  
    <property>  
        <name>dfs.name.dir</name>  
        <value>/usr/hadoop/hdfs/name</value>  
        <description>namenode上存储hdfs名字空间元数据 </description>   
    </property>  
    <property>  
        <name>dfs.data.dir</name>  
        <value>/usr/hadoop/hdfs/data</value>  
        <description>datanode上数据块的物理存储位置</description>  
    </property>  
    <property>  
        <name>dfs.replication</name>  
        <value>1</value>  
    </property>  
</configuration> 
EOF


cat >>mapred-site.xml <<EOF
<configuration>
        <property>
            <name>mapreduce.framework.name</name>
            <value>yarn</value>
        </property>
</configuration>
EOF



cat >>yarn-site.xml <<EOF
<configuration>  
    <property>  
            <name>yarn.nodemanager.aux-services</name>  
            <value>mapreduce_shuffle</value>  
    </property>  
    <property>  
            <name>yarn.resourcemanager.webapp.address</name>  
            <value>192.168.2.10:8099</value>  
            <description>这个地址是mr管理界面的</description>  
    </property>  
</configuration>  
EOF

mkdir -p /usr/hadoop/{tmp,hdfs,hdfs/{data,name}}

#添加变量
echo 'export HADOOP_HOME=/app/hadoop3.1' >>/etc/profile
echo 'PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >>/etc/profile
source /etc/profile

hadoop namenode -format

cd /app/hadoop3.1/sbin
# 以下四个文件还应该手动添加# 必须将其全部放到首部位 到顶部 这里暂时没想到追加到文件顶部的方法 
#采用sed 方法进行分段追加 使用sed 1a 在第一行进行追加同时备份
#因为root用户不能启动hadoop要用haddop用户 太过于麻烦直接输入以下指令
sed -ie.bak '1a HDFS_DATANODE_USER=root\nHADOOP_SECURE_DN_USER=hdfs\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root' start-dfs.sh
sed -ie.bak '1a HDFS_DATANODE_USER=root\nHADOOP_SECURE_DN_USER=hdfs\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root' stop-dfs.sh
sed -ie.bak '1a YARN_RESOURCEMANAGER_USER=root\nHADOOP_SECURE_DN_USER=yarn\nYARN_NODEMANAGER_USER=root' start-yarn.sh
sed -ie.bak '1a YARN_RESOURCEMANAGER_USER=root\nHADOOP_SECURE_DN_USER=yarn\nYARN_NODEMANAGER_USER=root' stop-yarn.sh


#cat >>start-dfs.sh <<EOF
#HDFS_DATANODE_USER=root
#HADOOP_SECURE_DN_USER=hdfs
#HDFS_NAMENODE_USER=root
#HDFS_SECONDARYNAMENODE_USER=root
#EOF

#cat >>stop-dfs.sh <<EOF
#HDFS_DATANODE_USER=root
#HADOOP_SECURE_DN_USER=hdfs
#HDFS_NAMENODE_USER=root
#HDFS_SECONDARYNAMENODE_USER=root
#EOF


#cat >>start-yarn.sh <<EOF
#YARN_RESOURCEMANAGER_USER=root
#HADOOP_SECURE_DN_USER=yarn
#YARN_NODEMANAGER_USER=root
#EOF

#cat >>stop-yarn.sh <<EOF
#YARN_RESOURCEMANAGER_USER=root
#HADOOP_SECURE_DN_USER=yarn
#YARN_NODEMANAGER_USER=root
#EOF

# 启动start-dfs 输入jps进行验证
start-dfs.sh
#start-dfs.sh 
jps

