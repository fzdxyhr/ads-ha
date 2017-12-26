package com.ruijie.adsha.service.impl;

import com.ruijie.adsha.constant.Constant;
import com.ruijie.adsha.constant.ResponseInfo;
import com.ruijie.adsha.service.MysqlGroupService;
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
 * Created by hp on 2017/12/26.
 */

@Service
@Slf4j
public class MysqlGroupServiceImpl implements MysqlGroupService {

    @Value("${mysql.container.name}")
    private String mysqlContainerName;
    @Value("${common.shell.path}")
    private String commonShellPath;
    @Value("${service.port}")
    private String port;

    @Override
    public ResponseInfo install(List<String> ips) {
       return null;
    }

    @Override
    public ResponseInfo start(List<String> ips) {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        List<String> params = new ArrayList<>();
        int returnResult;
        //调用远程其他集群中的主机接口，判断是否已经配置好组复制主机
        List<String> otherIps = getOtherIp();
        boolean isExistRemoteMasterGroup = requestRemote(otherIps);
        //开始安装MYSQL组复制
        if (isExistRemoteMasterGroup) {//MYSQL组复制已被集群中其他计算机配置，本机按照配机添加 type=slave
            log.info("start slave config");
            params.clear();
            params.add(Constant.MYSQL_TYPE_SLAVE);
            params.add(mysqlContainerName);
            params.addAll(ips);
            returnResult = ShellCall.callScript(commonShellPath, "start_group_mysql.sh", params);
            if (returnResult != 0) {
                responseInfo = new ResponseInfo(500, "MYSQL/FAIL", "mysql start fail");
            }
        } else { //MYSQL组复制以本机为主,type = master
            log.info("start master config");
            params.clear();
            params.add(Constant.MYSQL_TYPE_MASTER);
            params.add(mysqlContainerName);
            params.addAll(ips);
            returnResult = ShellCall.callScript(commonShellPath, "start_group_mysql.sh", params);
            if (returnResult != 0) {
                responseInfo = new ResponseInfo(500, "MYSQL/FAIL", "mysql start fail");
            }
        }
        return responseInfo;
    }

    @Override
    public ResponseInfo stop() {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //修改MYSQL配置文件并重启
        int returnResult = ShellCall.callScript(commonShellPath + "stop_group_mysql.sh");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "MYSQL/FAIL", "group mysql stop fail");
        }
        return responseInfo;
    }

    @Override
    public ResponseInfo uninstall() {
        return null;
    }

    private boolean requestRemote(List<String> ips) {
        try {
            for (String ip : ips) {
                String result = HttpUtils.get("http://" + ip + ":" + port + "/ads-ha/v1/ha/valid_mysql_group", "");
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
    public List<String> getOtherIp() {
        List<String> result = new ArrayList<>();
        String ipString = ShellCall.callScriptString(commonShellPath + "sed_value.sh");
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
