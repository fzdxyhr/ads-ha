package com.ruijie.adsha.service.impl;

import com.ruijie.adsha.constant.Constant;
import com.ruijie.adsha.constant.ResponseInfo;
import com.ruijie.adsha.service.AdsHaService;
import com.ruijie.adsha.service.KeepalivedService;
import com.ruijie.adsha.service.MysqlGroupService;
import com.ruijie.adsha.service.RsyncService;
import com.ruijie.adsha.shell.ShellCall;
import com.ruijie.adsha.util.HttpUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import sun.net.www.http.KeepAliveCache;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by hp on 2017/12/18.
 */

@Service
@Slf4j
public class AdsHaServiceImpl implements AdsHaService {

    @Value("${common.shell.path}")
    private String commonShellPath;
    @Value("${service.port}")
    private String port;
    @Autowired
    private MysqlGroupService mysqlGroupService;
    @Autowired
    private KeepalivedService keepalivedService;
    @Autowired
    private RsyncService rsyncService;

    @Override
    public ResponseInfo startHa(String virtualIp, List<String> ips) {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开始执行初始化文件，调用init_global.sh脚本进行全局数据的初始化
        List<String> reSortIps = new ArrayList<>();
        //虚拟ip放在最前面作为sh脚本的参数，具体传值可以查看对应的脚本注释
        reSortIps.add(virtualIp);
        reSortIps.addAll(ips);
        // ./init_global vistualIp ip1 ip2 ip3 ...
        int returnResult = ShellCall.callScript(commonShellPath, "init_global.sh", reSortIps);
        if (returnResult != 0) {
            //初始化失败直接返回
            return new ResponseInfo(500, "INIT/FAIL", "init global fail");
        }
        //配置 MYSQL
        if (mysqlGroupService.start(ips)) {
            return new ResponseInfo(500, "MYSQL/FAIL", "group mysql start/install fail");
        }
        //安装 Keepalived
        if (keepalivedService.install()) {
            return new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived install/start fail");
        }
        try {
            Thread.sleep(5000);
        } catch (Exception ex) {
        }
        //根据虚拟ip判断当前以哪台计算机为主,用于rsync初始启动的时候进行文件的同步
        initMasterState(virtualIp);
        //安装 rsync
        if (rsyncService.install()) {
            return new ResponseInfo(500, "RSYNC/FAIL", "rsync install/start fail");
        }
        return responseInfo;
    }

    @Override
    public ResponseInfo stopHa() {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all stop");
        //修改MYSQL配置文件并重启
        int returnResult = ShellCall.callScript(commonShellPath + "stop_group_mysql.sh");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "MYSQL/FAIL", "group mysql stop fail");
        }
        //停止rsync
        returnResult = ShellCall.callScript(commonShellPath + "start_rsync.sh stop");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync stop fail");
        }
        //停止keepalived
        returnResult = ShellCall.callScript(commonShellPath + "start_keepalived.sh stop");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived stop fail");
        }
        return responseInfo;
    }

    @Override
    public boolean validIsConfigMasterGroup() {
        int result = ShellCall.callScript(commonShellPath + "validIsConfigMasterGroup.sh loose-group");
        if (result == 0) {
            return true;
        }
        return false;
    }

    @Override
    public ResponseInfo remove() {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all stop");
        //修改MYSQL配置文件并重启
        int returnResult = ShellCall.callScript(commonShellPath + "stop_group_mysql.sh");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "MYSQL/FAIL", "group mysql remove fail");
        }
        //卸载rsync
        returnResult = ShellCall.callScript(commonShellPath + "start_rsync.sh uninstall");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync remove fail");
        }
        //卸载keepalived
        returnResult = ShellCall.callScript(commonShellPath + "start_keepalived.sh uninstall");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived remove fail");
        }
        return responseInfo;
    }

    @Override
    public boolean validAdsIsNormal() {
        return false;
    }

    public boolean validIsMasterKeepalived(String virtualIp) {
        int result = ShellCall.callScript(commonShellPath + "validIsMasterKeepalived.sh " + virtualIp);
        log.info("virtualIp:" + virtualIp + "input:" + result);
        if (result == 0) {
            return true;
        }
        return false;
    }

    private void initMasterState(String virtualIp) {
        if (validIsMasterKeepalived(virtualIp)) {//当前机为主机
            //更新全局变量指定该机为主机
            ShellCall.callScript(commonShellPath + "update_global.sh 1");
        } else {//当前机为备机
            //更新全局变量指定该机为备机
            ShellCall.callScript(commonShellPath + "update_global.sh 0");
        }
    }

    private void uninstall(String command) {
        int returnResult = ShellCall.callScript(commonShellPath + command);
        if (returnResult != 0) {
            log.info(command + "run is fail");
        }
    }
}
