#!/bin/bash

## 遍历所以以.sh结尾的文件
function getDir(){
    for element in `ls $1`
    do
        dir_or_file=$1"/"$element
        if [ -d $dir_or_file ];then
            getdir $dir_or_file
        else
            ## 只处理以.sh结尾的文件
            if [ "${dir_or_file##*.}"x = "sh"x ];then
                ##判断是否具有可执行权限，没有的话赋予可执行权限
                if [ ! -x "$dir_or_file" ]; then
                    chmod 777 $dir_or_file
                fi
            fi
        fi
    done
}

rootDir=$1
getdir $rootDir
