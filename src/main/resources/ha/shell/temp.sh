#!/bin/bash

echo "dsfsdfs" >> /home/software/temp.log
#因为keepalived重试次数设置了3，所以，这个文件要在第三次才去删除
exit 0