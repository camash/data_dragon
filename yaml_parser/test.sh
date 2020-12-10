#!/bin/sh

# include parse_yaml function
. yaml_parser.sh

# read yaml file
eval $(parse_yaml "/Users/shenfeng/Develop/data_dragon/yaml_parser/database.yml" "config_")

# access yaml content
echo $config_spring_datasource_password
