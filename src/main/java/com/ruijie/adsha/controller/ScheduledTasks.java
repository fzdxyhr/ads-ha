package com.ruijie.adsha.controller;

import com.ruijie.adsha.shell.ShellCall;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Created by YHR on 2017/12/15.
 */

@Component
@Slf4j
public class ScheduledTasks {

    @Value("${recovery.err.file.path}")
    public  String ERR_LOG_FILE_PATH;
    @Value("${mysql.container.name}")
    private String mysqlContainerName;
    @Value("${monitor.mysql.error.times}")
    private int monitorErrorTimes;

    //默认校验5次创建错误日志
    private int monitorTimes = monitorErrorTimes;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Scheduled(fixedRate = 100000)
    public void checkMysqlService() {
        StringBuffer sql = new StringBuffer();
        sql.append("select 1");
        try {
            jdbcTemplate.execute(sql.toString());
            //TODO 监听tomcat docker 容器状态
            if (!isTomcatDockerRunning(mysqlContainerName)) {
                throw new Exception("Tomcat is fail");
            }
            //mysql 和tomcat 都正常时删除错误文件
            int result = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "rm_dir.sh " + ERR_LOG_FILE_PATH);
            if (result != 0) {
                log.error("remove Recovery_err fail");
            }
        } catch (Exception ex) {
            log.error("mysql service fail", ex);
            if (monitorTimes == 0) {
                //数据库服务失败,创建一个错误日志文件
                ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "createErrorFile.sh");
                monitorTimes = monitorErrorTimes;
            } else {
                monitorTimes--;
            }
        }
    }

    private boolean isTomcatDockerRunning(String mysqlContainerName) {
        int result = ShellCall.callScript(ShellCall.COMMON_SHELL_PATH + "createErrorFile.sh " + mysqlContainerName);
        if (result == 0) {
            return true;
        }
        return false;
    }
}
