#!/bin/bash

# [1] 查询xxx.a 静态库所在的路径
# [2] 查询一个符号所在的静态库

#LIB库路径
if [ "${MACHTYPE}" = "x86_64-suse-linux" ]; then
	#系统lib库
	LIB_PATH="/usr/lib64"
	LIB_MYSQL_PATH="/usr/lib64/mysql"
	#基础库
	LIB_EXPORT_PATH="${C2C_BASE_PATH}/comm/export_lib_suse64"
	#SNS对外API
	LIB_SNSAPI_PATH="${C2C_BASE_PATH}/paipaiapi_sns/lib_suse64"
	#VB2C业务对外API
	LIB_VB2CAPI_PATH="${C2C_BASE_PATH}/paipaiapi_vb2c/lib_suse64"
	#基础业务对外API
	LIB_BASEAPI_PATH="${C2C_BASE_PATH}/paipaiapi_c2c/lib_suse64"
else
	LIB_PATH="/usr/lib"
	LIB_MYSQL_PATH="/usr/lib/mysql"
	LIB_EXPORT_PATH="${C2C_BASE_PATH}/comm/export_lib"
	LIB_SNSAPI_PATH="${C2C_BASE_PATH}/paipaiapi_sns/lib_suse32"
	LIB_VB2CAPI_PATH="${C2C_BASE_PATH}/paipaiapi_vb2c/lib_suse32"
	LIB_BASEAPI_PATH="${C2C_BASE_PATH}/paipaiapi_c2c/lib_suse32"
	
	if [ "${MACHTYPE}" = "i686-suse-linux" ]; then
		LIB_EXPORT_PATH="${C2C_BASE_PATH}/comm/export_lib_suse32"
	fi
fi

ALL_PATH="${LIB_PATH} ${LIB_MYSQL_PATH} ${LIB_EXPORT_PATH} ${LIB_SNS_PATH} ${LIB_SNSAPI_PATH} "
ALL_PATH+="${LIB_VB2CAPI_PATH} ${LIB_BASEAPI_PATH} ${LIB_AUCTION_PATH} "


function print_help()
{
	echo "./find_lib.sh [1] [xxx.a]  [查询.a所在的文件路径]";
	echo "./find_lib.sh [2] [symbol] [查询一个符号所在的.a文件名]";
}
if [ $# -lt 2 ]; then
	print_help
	exit 1
fi

case $1 in
	"1")
		FILE="$2"
		if [ "${FILE##*.}" != "a" ]; then
			echo "File format is worong, which should be end with .a"
			exit 1
		fi 
		find $ALL_PATH -name $2
	;;
	"2")
		SYMB="$2"
		for cur_path in $ALL_PATH
		do
			nm -CA ${cur_path}/*.a 2>/dev/null | grep -s $SYMB 
		done
	;;
	*)
		print_help
	;;
esac
