#!/bin/bash

# AUTHOR: SF
# DATE: 2019.11.05

# 访问公共文件的配置文件
source /home/hadoop/common/func.sh


# 记录开始时间
START_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# 获取当前执行脚本名称
FILE_NAME=`basename -- "$0" | cut -f1 -d'.'`

# 日志路径
SHELL_LOG="${ETL_HOME}/shell/logs"

# 获取用户输入日期, 加入日志延期
RUN_DATE=`date -d "$1 -0 days" +%Y%m%d`
ETL_DATE=`date -d "$1 -${DELAY} days" +%Y%m%d`

# 验证用户输入日期是否合理
check_date $RUN_DATE

if [ $? -eq 1 ];then
    echo_red "date format error! date format:(<yyyymmdd>)"
    exit 1
fi

echo_green "Input date : $RUN_DATE"
echo_green "Batch date : $ETL_DATE"

# 初始化日志
echo "开始时间:"$START_TIME > "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"

# 获取用户输入日期，并取上日
ETL_DATE_BE=`date -d "${ETL_DATE} -1 days" +%Y%m%d`

# 获取日期的横线分隔格式
ETL_DATE_DASH=`date -d "${ETL_DATE}" +%Y-%m-%d`

# 获得远程目录地址
SCP_DIR="${SCP_LOG}/d_date=${ETL_DATE_DASH}"

# 检查远程文件数
S_FILE_CNT=$(ssh -n ftpuser@${SCP_SERVER} "ls -1 ${SCP_DIR}| wc -l")
echo ${S_FILE_CNT}
if [ ${S_FILE_CNT} -gt 5 ];then
   echo_green "There are ${S_FILE_CNT} parquet files in SFTP" | tee -a "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"
else
   echo_red "Please check parquet files in SFTP, path is: ${SCP_DIR}." | tee -a "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"
   exit 1
fi

# 检查本地路径
ODS_TABLE_NAME="ods_d_log"
LOCAL_PATH=${LOCAL_ODS}/${ODS_TABLE_NAME}/${ETL_DATE}
echo "Local PATH is: ${LOCAL_PATH}"
if [ -d "${LOCAL_PATH}" ]; then
    echo_green "$LOCAL_PATH} is exist, start deleting..." | tee -a "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"
    rm -f "${LOCAL_PATH}"/*
    else
    echo_green "${LOCAL_PATH} is not exist, start creating..." | tee -a "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"
    mkdir -p "${LOCAL_PATH}"
fi

# 复制文件到本地
scp ftpuser@${SCP_SERVER}:${SCP_DIR}/* ${LOCAL_PATH}
if [ $? -eq 0 ];then
   echo_green "SCP transfer is done!" | tee -a "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"
else
   echo_red "SCP transfer exception, please check logs." | tee -a "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"
   exit 1
fi

# 文件数检查和比较
L_FILE_CNT=$(ls -1 ${LOCAL_PATH}| wc -l)
if [ ${S_FILE_CNT} -eq ${L_FILE_CNT} ]; then
    echo_green "Total ${L_FILE_CNT} parquet files is trasfered." | tee -a "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"
else
    echo_red "Source parquet files count diff with local, please check." | tee -a "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"
fi

# 调度结束时间
END_TIME=$(date "+%Y-%m-%d %H:%M:%S")


# 将开始结束时间打印到日志,并输出
echo "结束时间:"$END_TIME >> "${SHELL_LOG}/${FILE_NAME}.${ETL_DATE}.log"
echo "开始时间:"$START_TIME
echo "结束时间:"$END_TIME

