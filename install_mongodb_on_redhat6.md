#ReadHat 6 安装 mongodb 并设置开机启动

#Step1. 上传安装包到服务器的特定目录下
#Step2. root用户登录并解压安装的指定目录下（以/dagobah/mongodb/为例）
`mkdir /dagobah`
`tar -zxf mongodb-linux-x86_64-rhel62-4.0.2.tgz -C /dagobah`
`cd /dagobah`
`mv mongodb-linux-x86_64-rhel62-4.0.2 mongodb`

## 创建数据文件保存目录、创建日志文件
`cd mongodb`
`mkdir /dagobah/mongodb/dbs`
`touch /dagobah/mongodb/logs`

#Step3 设置开机启动

## 创建mongodb启动配置文件, 输入以下内容
`vi /dagobah/mongodb/mongod.conf`

verbose = true
bind_ip = 0.0.0.0
port = 27017
logpath = /dagobah/mongodb/logs
logappend = true
dbpath = /dagobah/mongodb/dbs
fork = true
quiet = true

## 创建开机启动文件，输入以下内容
`vi /etc/init.d/mongodb`

#!/bin/sh

### BEGIN INIT INFO
# Provides:     mongodb
# Required-Start:
# Required-Stop:
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description: mongodb
# Description: mongo db server
### END INIT INFO

EXE_FILE=/dagobah/mongodb/bin/mongod
CONFIG_FILE=/dagobah/mongodb/mongod.conf

. /lib/lsb/init-functions
MONGOPID=`ps -ef| grep mongod| grep -v grep| awk '{print $2}'`
test -x $EXE_FILE || exit 0

case "$1" in
  start)
    ulimit -n 3000
    log_begin_msg "Starting MongoDB server"
    $EXE_FILE --config $CONFIG_FILE
    log_end_msg 0
    ;;
  stop)
    log_begin_msg "Stopping MongoDB server"
    if [ ! -z "$MONGOPID" ]; then
        kill -15 $MONGOPID
    fi
    log_end_msg 0
    ;;
  status)
    ps -aux| grep mongod
    ;;
  *)
    log_success_msg "Usage: /etc/init.d/mongodb {start|stop|status}"
    exit 1
esac

exit 0


## 开机启动文件需要可执行权限
`chmod 755 /etc/init.d/mongodb`

## 设置开机启动
`chkconfig mongodb on`

## 查看
`chkconfig --list mongodb`
mongodb         0:off   1:off   2:on    3:on    4:on    5:on    6:off

#Step3 启动
`/dagobah/mongodb/bin/mongod -f /dagobah/mongodb/mongod.conf`
`pstree -p | grep mongo`
`service mongodb status`
