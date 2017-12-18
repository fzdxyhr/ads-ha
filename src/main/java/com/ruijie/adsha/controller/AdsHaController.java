package com.ruijie.adsha.controller;

import com.ruijie.adsha.constant.ResponseInfo;
import com.ruijie.adsha.service.AdsHaService;
import com.ruijie.adsha.shell.ShellCall;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by hp on 2017/12/14.
 */

@RestController
@RequestMapping("/v1")
public class AdsHaController {

    @Autowired
    private AdsHaService adsHaService;

    @RequestMapping(value = "/ha/start", method = RequestMethod.GET)
    public ResponseInfo startHa(@RequestParam("virtual_ip") String virtualIp, @RequestParam("ips") List<String> ips) {

        return adsHaService.startHa(virtualIp, ips);
    }

    @RequestMapping(value = "/ha/stop", method = RequestMethod.GET)
    public ResponseInfo stopHa() {
        return adsHaService.stopHa();
    }

    @RequestMapping(value = "/ha/valid_mysql_group", method = RequestMethod.GET)
    public boolean validMysqlGroup() {
        return adsHaService.validIsConfigMasterGroup();
    }

    @RequestMapping(value = "/ha/test", method = RequestMethod.GET)
    public String test() {
        return "test";
    }
}
