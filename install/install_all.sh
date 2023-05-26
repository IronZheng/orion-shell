#!/bin/sh

# 显示选项列表
echo "Please select an action:"
echo "1. java8"
echo "2. maven"
echo "3. nginx"
echo "4. docker"
echo "5. nodejs"

# 获取用户的选择
read -p "Enter your choice (1-4): " CHOICE

node(){
  # node v18

  node=node-v18.16.0-linux-x64
  wget https://nodejs.org/dist/v18.16.0/${node}.tar.xz

  tar -xf ${node}.tar.xz

  ln -s ${pwd}/${node}/bin/node /usr/local/bin/node
  ln -s ${pwd}/${node}/bin/npm /usr/local/bin/npm

  echo 'export PATH=$PATH:${pwd}/${node}/bin' | sudo tee -a /etc/profile

  node -v
  npm -v
}
#检查程序是否在运行
maven(){
  #!/bin/bash
  DIR="/home/soft/maven"
  if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
  fi
  cd $DIR

  #得到时间
  TIME_FLAG=`date +%Y%m%d_%H%M%S`
  #备份配置文件
  cp /etc/profile /etc/profile.bak_$TIME_FLAG
  echo -e "Begin to install maven,Please waiting..."
  #解压maven
  wget https://dlcdn.apache.org/maven/maven-3/3.9.2/binaries/apache-maven-3.9.2-bin.tar.gz
  tar zxvf apache-maven-*-bin.tar.gz
  mkdir /usr/local/maven
  mv apache-maven-*/* /usr/local/maven
  #修改maven的环境变量，直接写入配置文件
  echo "#MAVEN_HOME" >>/etc/profile
  echo "export MAVEN_HOME=/usr/local/maven" >>/etc/profile
  echo "export PATH=\$PATH:\$MAVEN_HOME/bin" >>/etc/profile
  #运行后直接生效
  source /etc/profile
  echo -e "Maven installation completed"
}

nginx(){
  #!/bin/bash
  [ $(id -u) != "0" ]&& echo "error,not root user" && exit 1
  #检测当前用户是否为root用户
  if [ ! -d /opt ];then
  #判断/opt目录是否存在
  mkdir /opt && cd /opt
  else
  cd /opt
  fi

  a=nginx-1.17.6
  wget http://nginx.org/download/${a}.tar.gz

  if [ $? -eq 0 ];then
  #下载完成后$?的值，如果等于0则解压，不等于0则异常退出
  tar zxf $a.tar.gz
  else
  echo "下载错误！"
  exit 1
  fi
  nginxu=`awk -F: '$0~/nginx/' /etc/passwd|wc -l`
  nginxg=`awk -F: '$0~/nginx/' /etc/group|wc -l`
  #给nginx用户和组设置变量
  if [ $nginxu -ne 0 ] && [ $nginxg -ne 0 ];then
  #判断nginx用户和组是否存在，不存在则创建
  echo "nginx用户和组已存在"
  else
  useradd -M -s /sbin/nologin nginx
  fi
  yum install gcc gcc-c++ pcre pcre-devel zlib-devel openssl openssl-devel libtool -y
  cd /opt/$a
  CFLAGS=" -pipe  -O -W -Wall -Wpointer-arith -Wno-unused-parameter -g" ./configure \
  --prefix=/usr/local/nginx \
  --user=nginx \
  --group=nginx \
  --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module
  make && make install
  if [ $? -eq 0 ];then
  #安装成功$?输出为0时，创建nginx命令软链接。
  ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/
  else
  echo "安装失败!!!"
  fi
}

docker(){
  curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
  docker -v
}

jdk8(){
  #!/bin/bash
  #offline jdk install
  # jdk安装目录
  ipath="/home/soft/java"
  installpath=$(cd `dirname $0`; pwd)
  j=`whereis java`
  java=$(echo ${j} | grep "jdk")
  if [[ "$java" != "" ]]
  then
      echo "java was installed!"
  else
      echo "java not installed!"
      echo;
      echo "解压 jdk-*-linux-x64.tar.gz"
      tar -zxvf jdk-*-linux-x64.tar.gz >/dev/null 2>&1
      echo;
      cd jdk* && jdkname=`pwd | awk -F '/' '{print $NF}'`
      echo "获取jdk版本: ${jdkname}"
      echo;
      cd ${installpath}
      echo "获取当前目录:${installpath}"
      echo;
      mv ${jdkname} ${ipath}
      echo "转移${jdkname}文件到${ipath}安装目录"
      echo "jdk安装目录:${ipath}/${jdkname}"
      echo;
      echo "#java jdk" >> /etc/profile
      echo "export JAVA_HOME=${ipath}/${jdkname}" >> /etc/profile
      echo 'export JRE_HOME=${JAVA_HOME}/jre' >> /etc/profile
      echo 'export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib' >> /etc/profile
      echo 'export PATH=${JAVA_HOME}/bin:$PATH' >> /etc/profile
      source /etc/profile > /dev/null 2>&1
      echo "jdk 安装完毕!"
      echo;
      echo "生效检测"
      echo;
      echo "检测java功能"
      java
      echo;
      echo "检测javac功能"
      javac
      echo;
      echo "检测java版本"
      java -version
      echo;
  fi
}

# 根据用户的选择执行对应的操作
case $CHOICE in
    1)
        echo "Starting install jdk8 ..."
        jdk8
        ;;
    2)
        echo "Starting install maven..."
        maven
        ;;
    3)
        echo "Stopping nginx..."
        nginx
        ;;
    4)
        echo "Restarting docker..."
        docker
        ;;
    5)
        echo "Checking status..."
        node
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac
exit 0