#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh

masterState="masterState=$1"
sed -i "s/^masterState=.*$/$masterState/g" $SHELL_PATH/global.sh

exit 0