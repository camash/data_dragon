# 作用
在Excel中配置任务依赖关系，然后使用shell脚本快速生成Azkaban的job文件。

# 方法
* 创建文件
|编号|任务名称|任务调用脚本|依赖|
|--- |--------|------------|----|
|000|start_kettle|||
|001|test|/home/hadoop/test/kettle/all/test.sh resource|000_start_kettle|

复制到文本文件中，然后执行shell脚本。
