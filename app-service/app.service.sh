#!/bin/sh
###########################
# 服务控制脚本
# 2018-12-12
###########################
config_path=`dirname $0`/app.config

#加载配置文件
. $config_path

RETVAL=0

logout(){
	msg="`date +%Y-%m-%d_%H:%M:%S` - $1"
	echo $1
	echo $msg >> $log_file
}

#根据输入的pid路径判断进程是否有效
#1. 判断pid文件是否存在
#2. 判断pid中的进程号在 /proc/$pid 是否存在
# 返回值 0: 正在运行,1: pid文件不存在,2: pid文件存在,进程不存在
status() {
	pidfile=$1
	if test -f $pidfile ; then
		runpids=$(cat $pidfile)
		if test -d "/proc/$runpids"  ; then
			echo "$app_name is running, pid:$runpids"
			return 0
		else
			echo "$pidfile exist, but $runpids is killed ."
			return 2
		fi
	else
		echo "$pidfile is not exist!"
		return 1
	fi
}

case "$1" in
start)
	echo "Starting up app ..."
	status $pid_file
	if test $? -eq 0 
	then
		echo "程序已启动, 请停止后再启动"
		exit -1
	fi
	java -jar $JAVA_OPTS $app_home${app_file_name} >> $app_log_file &
	pidnum=$!
	echo $pidnum > $pid_file
	logout "$app_name 已启动"
	logout "pid num : $pidnum"
	logout "pid file: $pid_file"
	echo
;;
stop)
	echo "Shutting down app ..."
	# status 返回值不等于0 则
	status $pid_file
	if test $? -ne 0 
	then
		echo "进程已停止"
		exit 0
	fi
	runpids=$(cat $pid_file)
	logout "正在停止$app_name, 进程号: $runpids"
	kill $runpids
	RETVAL=$?
	if test $RETVAL -eq 0 
	then
		logout "$app_name正常结束"
		rm -rf $pid_file
	else
		logout "正常结束失败, 尝试强制结束"
		kill -9 $runpids
		RETVAL=$?
		if test $RETVAL -eq 0 
		then
			logout "$app_name 强制结束成功"
			rm -rf $pid_file
		else
			logout "$app_name 结束失败!!! 请手动结束"
		fi
	fi
	echo
;;
restart)
	$0 stop
	logout "延时 3秒"
	sleep 3
	$0 start
;;
status)
	status $pid_file
	RETVAL=$?
;;
*)
	echo "Usage: $0 {start|stop|status|restart}"
	exit 1
;;
esac
exit $RETVA
