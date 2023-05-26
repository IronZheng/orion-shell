#!/bin/sh

# 显示选项列表
echo "Please select an action:"
echo "1. maven"
echo "2. Stop"
echo "3. Restart"
echo "4. Status"

# 获取用户的选择
read -p "Enter your choice (1-4): " CHOICE

#检查程序是否在运行
maven(){
  #!/bin/bash
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

# 根据用户的选择执行对应的操作
case $CHOICE in
    1)
        echo "Starting install maven..."
        maven
        ;;
    2)
        echo "Stopping service..."
        # 执行停止操作
        ;;
    3)
        echo "Restarting service..."
        # 执行重启操作
        ;;
    4)
        echo "Checking status..."
        # 执行状态查询操作
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac
exit 0