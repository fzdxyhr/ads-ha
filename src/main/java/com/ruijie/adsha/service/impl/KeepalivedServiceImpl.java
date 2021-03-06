package com.ruijie.adsha.service.impl;

import com.ruijie.adsha.constant.ResponseInfo;
import com.ruijie.adsha.service.KeepalivedService;
import com.ruijie.adsha.shell.ShellCall;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by hp on 2017/12/26.
 */

@Service
public class KeepalivedServiceImpl implements KeepalivedService {

    @Value("${common.shell.path}")
    private String commonShellPath;

    @Override
    public boolean install() {
        boolean result = true;
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        List<String> params = new ArrayList<>();
        params.add("install");
        //安装 keepalived
        int returnResult = ShellCall.callScript(commonShellPath, "start_keepalived.sh", params);
        if (returnResult != 0) {
            result = false;
        }
        return result;
    }

    @Override
    public boolean start() {
        boolean result = true;
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_keepalived.sh start");
        if (returnResult != 0) {
//            responseInfo = new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived start fail");
            result = false;
        }
        return result;
    }

    @Override
    public boolean stop() {
        boolean result = true;
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_keepalived.sh stop");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived stop fail");
            result = false;
        }
        return result;
    }

    @Override
    public boolean uninstall() {
        boolean result = true;
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_keepalived.sh uninstall");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "KEEPALIVED/FAIL", "keepalived uninstall fail");
            result = false;
        }
        return result;
    }

    @Override
    public boolean config() {
        boolean result = true;
        //配置并开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_keepalived.sh config");
        if (returnResult != 0) {
            result = false;
        }
        return result;
    }
}
