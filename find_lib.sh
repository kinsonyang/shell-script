#!/bin/bash

# [1] ��ѯxxx.a ��̬�����ڵ�·��
# [2] ��ѯһ���������ڵľ�̬��

#LIB��·��
if [ "${MACHTYPE}" = "x86_64-suse-linux" ]; then
	#ϵͳlib��
	LIB_PATH="/usr/lib64"
	LIB_MYSQL_PATH="/usr/lib64/mysql"
	#������
	LIB_EXPORT_PATH="${C2C_BASE_PATH}/comm/export_lib_suse64"
	#SNS����API
	LIB_SNSAPI_PATH="${C2C_BASE_PATH}/paipaiapi_sns/lib_suse64"
	#VB2Cҵ�����API
	LIB_VB2CAPI_PATH="${C2C_BASE_PATH}/paipaiapi_vb2c/lib_suse64"
	#����ҵ�����API
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
	echo "./find_lib.sh [1] [xxx.a]  [��ѯ.a���ڵ��ļ�·��]";
	echo "./find_lib.sh [2] [symbol] [��ѯһ���������ڵ�.a�ļ���]";
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
