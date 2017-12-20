package com.ruijie.adsha.controller;

import com.ruijie.adsha.constant.Constant;
import com.ruijie.adsha.shell.ShellCall;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

/**
 * Created by YHR on 2017/12/15.
 */

@Component
@Slf4j
public class ScheduledTasks {

    public static String ERR_DIR = "/opt/ads-ha/ha/logs/";

    //默认校验5次创建错误日志
    private int monitorTimes = Constant.MONITOR_TIMES;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Scheduled(fixedRate = 100000)
    public void checkMysqlService() {
        StringBuffer sql = new StringBuffer();
        sql.append("select 1");
        try {
            jdbcTemplate.execute(sql.toString());
            //TODO 监听tomcat docker 容器状态
        } catch (Exception ex) {
            log.error("mysql service fail", ex);
            if (monitorTimes == 0) {
                //数据库服务失败,创建一个错误日志文件
                ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "createErrorFile.sh");
                monitorTimes = Constant.MONITOR_TIMES;
            } else {
                monitorTimes--;
            }
        }
    }
}
