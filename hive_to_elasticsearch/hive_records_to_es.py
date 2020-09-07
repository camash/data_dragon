#!/usr/bin/env python
# -*- coding: UTF-8 -*-
from pyhive import hive
import json
from elasticsearch import Elasticsearch, helpers
from datetime import datetime, timedelta
import configparser

_index = 'target_index'   #修改为索引名
_type = _index     #修改为类型名
_bulk_num = 100000 # 批量提交限制


def tuple_to_dict(keys, values):
    """
    transfer the hive query tuple to
    :param keys:
    :param values:
    :return:
    """
    item = dict()
    for i in range(len(keys)):
        val = values[i]
        # 对数组类型做特别设定
        if keys[i] == "brand" and val:
            try:
                temp_val = val.replace('[','').replace(']','').replace('"','')
                val = temp_val.split(',')
            except:
                print("The KV Pair to List is error.".format(keys[i], val))
        item[keys[i]] = val

    #print(item)

    json_str = json.dumps(item, ensure_ascii=False)
    #print(json_str)

    return json_str


def hive_records_to_es():

    # read configuration
    config = configparser.ConfigParser()
    config.read('/home/hadoop/etl/python/connection.cfg')

    es_conf = config['es']
    es_url_1 = es_conf['es_url_1']
    es_url_2 = es_conf['es_url_2']
    es_url_3 = es_conf['es_url_3']
    es = Elasticsearch([es_url_1, es_url_2, es_url_3])

    hive_conf = config['hive']
    hive_host = hive_conf['host']
    hive_user = hive_conf['user']
    hive_port = hive_conf['port']

    column_str = "c1, c2, c3, c4, c5, c6, c7"
    column_list = column_str.split(",")
    current_date = datetime.strftime(datetime.now(), "%Y%m%d")
    previous_date = datetime.strftime(datetime.now() - timedelta(1), "%Y%m%d")
    # setup Hive connection
    conn = hive.Connection(host=hive_host, port=hive_port, username=hive_user)
    cursor = conn.cursor()
    cursor.execute("use target_db")

    print("Start to get data from Hive.")
    sql = "select " + column_str +\
          " from  target_table  " +\
          " where etl_date = " + current_date


    cursor.execute(sql)
    i = 0
    temp_list = []
    for row in cursor.fetchall():
        #print(row)
        json_str = tuple_to_dict(column_list, row)
        i = i + 1
        temp_list.append({
                    "_index": _index,
                    "_type": _type,
                    "_source": json_str
                })
        if i == _bulk_num:
            helpers.bulk(es, temp_list)
            temp_list.clear()
            print("Load {} records to es.".format(i))

    if temp_list:
        helpers.bulk(es, temp_list)
        print("Load {} records to es.".format(len(temp_list)))


if __name__ == '__main__':
    #tuple_to_dict(('a','b'),("c", "[a,b,c]"))
    hive_records_to_es()
