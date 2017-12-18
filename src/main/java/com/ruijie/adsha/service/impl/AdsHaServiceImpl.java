package com.ruijie.adsha.service.impl;

import com.ruijie.adsha.constant.Constant;
import com.ruijie.adsha.constant.ResponseInfo;
import com.ruijie.adsha.service.AdsHaService;
import com.ruijie.adsha.shell.ShellCall;
import com.ruijie.adsha.util.HttpUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by hp on 2017/12/18.
 */

@Service
@Slf4j
public class AdsHaServiceImpl implements AdsHaService {

    @Value("${mysql.container.name}")
    private String mysqlContainerName;

    @Override
    public ResponseInfo startHa(String virtualIp, List<String> ips) {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all start");
        //开始执行初始化文件，调用init_global.sh脚本进行全局数据的初始化
        List<String> reSortIps = new ArrayList<>();
        //虚拟ip放在最前面作为sh脚本的参数，具体传值可以查看对应的脚本注释
        reSortIps.add(virtualIp);
        reSortIps.addAll(ips);
        // ./init_global vistualIp ip1 ip2 ip3 ...
        int returnResult = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH, "init_global.sh", reSortIps);
        if (returnResult != 0) {
            //初始化失败直接返回
            return new ResponseInfo(500, "INIT/FAIL", "init global fail");
        }
        //安装 MYSQL
        //调用远程其他集群中的主机接口，判断是否已经配置好组复制主机
        List<String> otherIps = getOtherIp();
        boolean isExistRemoteMasterGroup = requestRemote(otherIps);
        //开始安装MYSQL组复制
        if (isExistRemoteMasterGroup) {//MYSQL组复制已被集群中其他计算机配置，本机按照配机添加 type=slave
            reSortIps.clear();
            reSortIps.add(Constant.MYSQL_TYPE_SLAVE);
            reSortIps.add(mysqlContainerName);
//            reSortIps.add(virtualIp);
            reSortIps.addAll(ips);
            returnResult = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH, "start_group_mysql.sh", reSortIps);
            if (returnResult != 0) {
                responseInfo = new ResponseInfo(500, "MYSQL/FAIL", "mysql start fail");
            }
        } else { //MYSQL组复制以本机为主,type = master
            reSortIps.clear();
            reSortIps.add(Constant.MYSQL_TYPE_MASTER);
            reSortIps.add(mysqlContainerName);
//            reSortIps.add(virtualIp);
            reSortIps.addAll(ips);
            returnResult = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH, "start_group_mysql.sh", reSortIps);
            if (returnResult != 0) {
                responseInfo = new ResponseInfo(500, "MYSQL/FAIL", "mysql start fail");
            }
        }
        reSortIps.clear();
        reSortIps.add("start");
        //安装 rsync
        returnResult = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH, "start_rsync.sh", reSortIps);
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync start fail");
        }
        //安装 keepalived
        returnResult = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH, "start_keepalived.sh", reSortIps);
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived start fail");
        }
        return responseInfo;
    }

    @Override
    public ResponseInfo stopHa() {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all stop");
        //修改MYSQL配置文件并重启
        int returnResult = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "stop_group_mysql.sh");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived stop fail");
        }
        //停止rsync
        returnResult = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "start_rsync.sh stop");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived stop fail");
        }
        //停止keepalived
        returnResult = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "start_keepalived.sh stop");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived stop fail");
        }
        return responseInfo;
    }

    @Override
    public boolean validIsConfigMasterGroup() {
        int result = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "validIsConfigMasterGroup.sh loose-group");
        if (result == 0) {
            return true;
        }
        return false;
    }

    private boolean requestRemote(List<String> ips) {
        try {
            for (String ip : ips) {
                String result = HttpUtils.get("http://" + ip + ":8080/ads-ha/v1/ha/valid_mysql_group", "");
                if ("true".equals(result)) {
                    return true;
                }
            }
        } catch (Exception ex) {
            log.error(ex.getMessage(), ex);
        }
        return false;
    }

    //从global.sh文件中获取除本机ip的其他ip
    private List<String> getOtherIp() {
        List<String> result = new ArrayList<>();
        String ipString = ShellCall.callScriptString(ShellCall.COMMON_SHELL_PATH + "sed_value.sh");
        if (StringUtils.isEmpty(ipString)) {
            return Collections.emptyList();
        }
        String[] ips = ipString.split(",");
        for (String ip : ips) {
            result.add(ip);
        }
        return result;
    }
}
