#!/bin/bash

cat joblist.txt | while read line
do
    job_code=`echo "${line}" | awk -F'\t' '{print $1}'`
    tab_name=`echo "${line}" | awk -F'\t'  '{print $2}'`
    shell_path=`echo "${line}" | awk -F'\t' '{print $3}'`
    dependency=`echo "${line}" | awk -F'\t' '{print $4}'`

    file_name="${job_code}_${tab_name}.job"
    #echo ${file_name}
    echo ${shell_path}
    #echo ${dependency}
    printf "type=command\n" > "${file_name}"
    if [ ! -z "$dependency" ]
    then
        printf "dependencies=%s\n" "${dependency}" >> "${file_name}"
    fi
    printf "command=/bin/bash %s '\${azkaban.flow.start.year}\${azkaban.flow.start.month}\${azkaban.flow.start.day}'" "${shell_path}" >> "${file_name}"
done
