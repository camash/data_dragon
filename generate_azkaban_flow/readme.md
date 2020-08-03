# 作用
在Excel中配置任务依赖关系，然后使用shell脚本快速生成Azkaban的job文件。

# 方法
* 创建文件
在Excel或者其它表格软件中，按如下结构创建

|编号|任务名称|任务调用脚本|依赖|
|--- |--------|--------|----|
|000|start_kettle|||
|001|test|/home/hadoop/test/kettle/all/test.sh resource|000_start_kettle|
|002|end_job|/home/hadoop/test/kettle/all/end_job.sh|000_start_kettle, 001_test|

* 执行转换
复制到文本文件中，保存为tsv文件，比如test.txt。然后执行shell脚本。

```shell
bash ./gen_azkaban_flow.sh test.txt
```

执行之后在文件所在路径内会生成以`编号_任务名称.job`的Azkaban任务文件。文件数量等同于tsv文件中的行数。

```shell
ls -1 *.job
000_start_kettle.job
001_test.job
002_end_job.job
```

* job文件内容

主要包含执行项和依赖项，依赖项就是最终生成任务DAG的边。
同时，这个脚本中默认会给执行命令加入执行日期参数，若不需要可以通过修改shell命令实现。

```shell
$ cat 002_end_job.job 
type=command
dependencies=000_start_kettle, 001_test
command=/bin/bash /home/hadoop/test/kettle/all/end_job.sh '${azkaban.flow.start.year}${azkaban.flow.start.month}${azkaban.flow.start.day}'
```



# 总结

可以通过先在表格中规则的梳理任务流，避免了任务太多时直接写job文件容易遗漏的情况。梳理完成之后，使用该脚本一次性生成所有的job，秒秒钟完成。