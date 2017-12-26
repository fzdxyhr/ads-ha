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
    public ResponseInfo install() {
        //安装 rsync
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        List<String> params = new ArrayList<>();
        params.add("install");
        int returnResult = ShellCall.callScript(commonShellPath, "start_rsync.sh", params);
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync install/start fail");
        }
        return responseInfo;
    }

    @Override
    public ResponseInfo start() {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_rsync.sh start");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync start fail");
        }
        return responseInfo;
    }

    @Override
    public ResponseInfo stop() {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_rsync.sh stop");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync stop fail");
        }
        return responseInfo;
    }

    @Override
    public ResponseInfo uninstall() {
        ResponseInfo responseInfo = new ResponseInfo(200, "SUCCESS", "all success");
        //开启keepalived
        int returnResult = ShellCall.callScript(commonShellPath + "start_rsync.sh uninstall");
        if (returnResult != 0) {
            responseInfo = new ResponseInfo(500, "RSYNC/FAIL", "rsync uninstall fail");
        }
        return responseInfo;
    }

    @Override
    public ResponseInfo config() {
        return null;
    }
}
