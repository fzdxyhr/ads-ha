package com.ruijie.adsha.controller;

import com.ruijie.adsha.shell.ShellCall;
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

    @RequestMapping(value = "/ha/start", method = RequestMethod.GET)
    public String startHa(@RequestParam("virtual_ip") String virtualIp, @RequestParam("ips") List<String> ips) {
        //开始执行初始化文件，调用init_global.sh脚本进行全局数据的初始化
        List<String> reSortIps = new ArrayList<>();
        //虚拟ip放在最前面作为sh脚本的参数，具体传值可以查看对应的脚本注释
        reSortIps.add(virtualIp);
        reSortIps.addAll(ips);
        ShellCall.callScript(ShellCall.COMMON_SHELL_PATH, "init_global.sh", reSortIps);
        //安装MYSQL
        //TODO 调用远程其他集群中的主机接口，判断是否已经配置好组复制主机
        ShellCall.callScript(ShellCall.COMMON_SHELL_PATH, "start_group_mysql.sh", reSortIps);
        //安装rsync
        ShellCall.callScript(ShellCall.COMMON_SHELL_PATH, "start_rsync.sh", reSortIps);
        //安装keepalived
        ShellCall.callScript(ShellCall.COMMON_SHELL_PATH, "start_keepalived.sh", reSortIps);
        return "success";
    }

    @RequestMapping(value = "/ha/stop", method = RequestMethod.GET)
    public String stopHa() {
        //清空全局对应的值
        ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "");
        //修改MYSQL配置文件并重启
        ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "stop_group_mysql.sh");
        //停止rsync
        ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "start_rsync.sh stop");
        //停止keepalived
        ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "start_keepalived.sh stop");
        return "success";
    }


}
