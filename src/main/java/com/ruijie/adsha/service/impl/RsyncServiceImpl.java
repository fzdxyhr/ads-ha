package com.ruijie.adsha.service.impl;

import com.ruijie.adsha.constant.ResponseInfo;
import com.ruijie.adsha.service.RsyncService;
import com.ruijie.adsha.shell.ShellCall;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by hp on 2017/12/26.
 */

@Service
public class RsyncServiceImpl implements RsyncService {

    @Value("${common.shell.path}")
    private String commonShellPath;

    @Override
    public boolean install() {
        //安装 rsync
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        boolean result = true;
        List<String> params = new ArrayList<>();
        params.add("install");
        int returnResult = ShellCall.callScript(commonShellPath, "start_rsync.sh", params);
        if (returnResult != 0) {
//            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync install/start fail");
            result = false;
        }
        return result;
    }

    @Override
    public boolean start() {
        boolean result = true;
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_rsync.sh start");
        if (returnResult != 0) {
//            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync start fail");
            result = false;
        }
        return result;
    }

    @Override
    public boolean stop() {
        boolean result = true;
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_rsync.sh stop");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync stop fail");
            result = false;
        }
        return result;
    }

    @Override
    public boolean uninstall() {
        boolean result = true;
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_rsync.sh uninstall");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync uninstall fail");
            result = false;
        }
        return result;
    }

    @Override
    public boolean config() {
        boolean result = true;
        //配置并开启start_rsync
        int returnResult = ShellCall.callScript(commonShellPath + "start_rsync.sh config");
        if (returnResult != 0) {
            result = false;
        }
        return result;
    }
}
