#!/bin/bash

otherIp=$(sed '/otherIp/!d;s/.*=//'  /opt/ads-ha/WEB-INF/classes/ha/shell/global.sh)
echo $otherIp