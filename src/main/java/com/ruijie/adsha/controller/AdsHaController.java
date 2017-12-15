package com.ruijie.adsha.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by hp on 2017/12/14.
 */

@RestController
@RequestMapping("/v1")
public class AdsHaController {

    @RequestMapping(value = "/ha/start",method = RequestMethod.GET)
     public String startHa(@RequestParam("virtual_ip") String virtualIp,@RequestParam("ips") List<String> ips){
        for (String ip : ips) {
            System.out.println(ip);
        }
        return "success";
    }



}
