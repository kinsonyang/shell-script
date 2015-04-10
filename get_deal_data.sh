#功能: get deal data 
#作者: kinsonyang 
#时间: 2014-04-13
#机器: 10.129.129.148
#定时: no 

#!/bin/bash

#source comm file
source /cfs/vshell/include/virtual.def


WORK_DIR="/cfs/vshell/virbiz_deal/"


#spilt the argments
ARGS=`getopt -a -o d:s:w:t:l:n:h -l db:,select:,where:,sql_dir:,data_dir:,table:,level:,name:,vsale:,data:,help -- "$@"`
eval set -- "${ARGS}"


DB="vdealdb_b"
LEVEL="s1" #default use slave1
NEED_DATA=1 #default need return data
USE_VSALE=0 #default need vsale

while true; do
	case "$1" in 
	-d|--db) DB=$2; shift ;; # db name
	-s|--select) SELECT=`echo $2`; shift ;; # select filed
	-w|--where) WHERE=`echo $2`; shift ;; # where condition
	-n|--name) NAME=$2; shift ;; # for file name 
	--level) LEVEL=$2; shift ;; # for host choice 
	--sql_dir) SQL_DIR=$2; shift ;; 
	--data_dir) DATA_DIR=$2; shift ;;
	--data) NEED_DATA=$2; shift ;; #Don't need excute for data
	--vsale) USE_VSALE=$2; shift ;; #Don't need vsale
	--) shift; break ;;
	esac
shift
done

#if not seller_db, then must be buyer_db
if [ "vdealdb_s" = $DB ] ; then
	TABLE="t_vir_deal_seller_"
else
	DB="vdealdb_b"
	TABLE="t_vir_deal_buyer_"
fi

#default use slave1
if [ "m" = $LEVEL ]; then
	G0_HOST=$VIRBIZ_DB_M0
	G0_PORT=$VIRBIZ_DB_M0_PORT
	G1_HOST=$VIRBIZ_DB_M1
	G1_PORT=$VIRBIZ_DB_M1_PORT
elif [ "s2" = $LEVEL ]; then
	G0_HOST=$VIRBIZ_DB_S0_2
	G0_PORT=$VIRBIZ_DB_S0_2_PORT
	G1_HOST=$VIRBIZ_DB_S1_2
	G1_PORT=$VIRBIZ_DB_S1_2_PORT
else
	G0_HOST=$VIRBIZ_DB_S0_1
	G0_PORT=$VIRBIZ_DB_S0_1_PORT
	G1_HOST=$VIRBIZ_DB_S1_1
	G1_PORT=$VIRBIZ_DB_S1_1_PORT
fi

#if null, then all
if [ -z "$SELECT" ] ; then
	SELECT="*" 
fi

#if where is null, it's forbidden
if [ -z "$WHERE" ]; then 
	echo '-w|--where is null'
	exit 1
fi

#you must give me a name, then i can give the file a name.
if [ -z "$NAME" ]; then 
	echo '-n|--name is null'
	exit 1
fi

#if you don't give me a sql_dir, I'll name it.
if [ -z "$SQL_DIR" ]; then 
	SQL_DIR="${WORK_DIR}/sql/"
elif [ ! -d $SQL_DIR ]; then 
	echo "${SQL_DIR} : no such dir" #Are you kidding?
	exit 1
fi

#if don't need data
if [ 1 -eq $NEED_DATA ]; then
	if [ -z "$DATA_DIR" ]; then
		echo "you need data? give me a dir, or use --NEED_DATA"
		exit 1
	elif [ ! -d $DATA_DIR ]; then
		echo "${DATA_DIR} : no such dir" #No kiddding
		exit 1
	fi
fi

G0_SQL="${SQL_DIR}/${NAME}_g0.sql" #even group
G1_SQL="${SQL_DIR}/${NAME}_g1.sql" #odd group

#generate the sql
#echo ${SELECT}
sed -e "s/__FIELD__/${SELECT}/g" -e "s/__TALBES__/${TABLE}/g" -e "s/__CONDITION__/${WHERE}/g" ${WORK_DIR}/virbiz_deal_group0.sql.tpl > ${G0_SQL} 
sed -e "s/__FIELD__/${SELECT}/g" -e "s/__TALBES__/${TABLE}/g" -e "s/__CONDITION__/${WHERE}/g" ${WORK_DIR}/virbiz_deal_group1.sql.tpl > ${G1_SQL}

#if need vsale, add them to sql file
if [ 1 -eq $USE_VSALE ]; then
	for vsale in ${VSALE_BUYER[@]}
	do
		if [ 0 -eq $(($vsale%2)) ]; then
			sed -e "s/__FIELD__/${SELECT}/g" -e "s/__TALBES__/${TABLE}/g" -e "s/__VSALE__/${vsale}/g" -e "s/__CONDITION__/${WHERE}/g" ${WORK_DIR}/virbiz_deal_vsale.sql.tpl >> ${G0_SQL}
		else
			sed -e "s/__FIELD__/${SELECT}/g" -e "s/__TALBES__/${TABLE}/g" -e "s/__VSALE__/${vsale}/g" -e "s/__CONDITION__/${WHERE}/g" ${WORK_DIR}/virbiz_deal_vsale.sql.tpl >> ${G1_SQL}
		fi
	done
fi

#Don't need data
if [ 0 -eq $NEED_DATA ]; then
	exit 0
fi

#query for the data
DATA_FILE="${DATA_DIR}/${NAME}_all.data"
mysql -uppvb2c -pvb2cpp --default-character-set=gbk -A -N -h${G0_HOST} -P${G0_PORT} ${DB} < $G0_SQL > $DATA_FILE
mysql -uppvb2c -pvb2cpp --default-character-set=gbk -A -N -h${G1_HOST} -P${G1_PORT} ${DB} < $G1_SQL >> $DATA_FILE
 
