package com.ruijie.adsha.controller;

import com.ruijie.adsha.constant.ResponseInfo;
import com.ruijie.adsha.service.AdsHaService;
import com.ruijie.adsha.shell.ShellCall;
import com.ruijie.adsha.util.HttpUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by hp on 2017/12/14.
 */

@RestController
@RequestMapping("/ads-ha")
public class AdsHaController {

    @Autowired
    private AdsHaService adsHaService;

    @RequestMapping(value = "/start", method = RequestMethod.GET)
    public ResponseInfo startHa(@RequestParam("virtual_ip") String virtualIp, @RequestParam("ips") List<String> ips) {
        return adsHaService.startHa(virtualIp, ips);
    }

    @RequestMapping(value = "/stop", method = RequestMethod.GET)
    public ResponseInfo stopHa() {
        return adsHaService.stopHa();
    }

    @RequestMapping(value = "/remove", method = RequestMethod.GET)
    public ResponseInfo remove() {
        return adsHaService.remove();
    }

    @RequestMapping(value = "/is_normal", method = RequestMethod.GET)
    public boolean validAdsIsNormal() {
        return adsHaService.validAdsIsNormal();
    }

    @RequestMapping(value = "/valid_mysql_group", method = RequestMethod.GET)
    public boolean validMysqlGroup() {
        return adsHaService.validIsConfigMasterGroup();
    }

    @RequestMapping(value = "/test", method = RequestMethod.GET)
    public ResponseInfo test(@RequestParam("virtual_ip") String virtualIp, @RequestParam("ips") List<String> ips) {
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
        return new ResponseInfo(200, "SUCCESS", "init global success");
    }

    @RequestMapping(value = "/test2", method = RequestMethod.GET)
    public List<String> getOtherIp() {
        List<String> result = new ArrayList<>();
        String ipString = ShellCall.callScriptString(ShellCall.COMMON_SHELL_PATH + "sed_value.sh");
        System.out.println("ip:" + ipString);
        if (StringUtils.isEmpty(ipString)) {
            return Collections.emptyList();
        }
        String[] ips = ipString.split(",");
        for (String ip : ips) {
            result.add(ip);
        }
        return result;

    }

    @RequestMapping(value = "/test3", method = RequestMethod.GET)
    public boolean test3() {
        List<String> result = new ArrayList<>();
        String ipString = ShellCall.callScriptString(ShellCall.COMMON_SHELL_PATH + "sed_value.sh");
        String[] ips = ipString.split(",");
        for (String ip : ips) {
            result.add(ip);
        }
        try {
            for (String ip : ips) {
                String aa = HttpUtils.get("http://" + ip + ":8080/ads-ha/v1/ha/valid_mysql_group", "");
                if ("true".equals(aa)) {
                    return true;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @RequestMapping(value = "/test4", method = RequestMethod.GET)
    public boolean test4(@RequestParam("virtual_ip") String virtualIp) {
        int result = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "validIsMasterKeepalived.sh " + virtualIp);
//        log.info("virtualIp:" + virtualIp + "input:" + result);
        if (result == 0) {
            return true;
        }
        return false;
    }


}
