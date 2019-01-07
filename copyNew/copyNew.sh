#!/bin/bash

#./copyNew.sh /mnt/d/ping /mnt/d/test 2018-12-28 

if [ $# -ne 3 ];then
	echo "请输入 param1:比较目录，param2:保存目录，param3:比较时间"
	exit 1
fi
echo "输入路径：$1"
echo "输出路径：$2"
echo "开始时间: $3"

INPUT_PATH=$1
OUTPUT_PATH=$2
TIME=`date -d $3 +%s`

#检测文件
checkFile(){
	local IN_PATH
	local dir
	IN_PATH=$1
	dir=`ls $IN_PATH`
	#echo "dir : $dir"
	for fi in $dir
	do
		fn=$IN_PATH/$fi
		#echo "fn : $fn"
		#目录
		if [ -d $fn ];then
			#echo "handle dir: $fn"
			checkFile $fn
		else 
		#文件
			#echo "$fn"
			compareFile $fn
		fi
		
	done

}

#比较文件时间
compareFile(){
	fn=$1
	ft=`stat -c %Y $fn`
	if [ $ft -gt $TIME ];then
		#echo $fn 需要处理
		copyFile $fn
	fi
}
#复制文件
copyFile(){
	IN_FILE=$1
	TARGET_FILE=${IN_FILE/$INPUT_PATH/$OUTPUT_PATH}
	#echo "target: "${TARGET_FILE}
	bp=` echo $TARGET_FILE | grep -P '/.+/' -o`
	#echo "目录:$bp"
	if [ ! -d $bp ];then
		mkdir -p $bp
	fi
	echo "copy : $IN_FILE"
	cp -f $IN_FILE $TARGET_FILE
}

checkFile $1

 
echo "拷贝完成"

