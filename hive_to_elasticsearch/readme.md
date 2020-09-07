# 作用
将Hive表中的数据导入到Elasticsearch的索引中。

# 方法
脚本是通过Python3编写的，因此使用Python3调用即可。

```python
python3 hive_records_to_es.py
```

其中，Hive地址和Elasticsearch的地址放在`connection.cfg`文件中，样例如下：
```shell
[hive]
host = 192.168.1.4
port = 10000
user = hadoop
[es]
es_url_1 = http://192.168.1.6:7200/
es_url_2 = http://192.168.1.7:7200/
es_url_3 = http://192.168.1.8:7200/
```

另外，表名和索引名在脚本中是静态赋值，后期需要动态传入。
