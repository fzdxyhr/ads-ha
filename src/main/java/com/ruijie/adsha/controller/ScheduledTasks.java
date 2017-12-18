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

    @Scheduled(fixedRate = 10000)
    public void checkMysqlService() {
        StringBuffer sql = new StringBuffer();
        sql.append("select 1");
        try {
            jdbcTemplate.execute(sql.toString());
//            System.out.println("task is running");
            //TODO 监听tomcat docker 容器状态
        } catch (Exception ex) {
            log.error("mysql service fail", ex);
            if (monitorTimes == 0) {
                //数据库服务失败,创建一个错误日志文件
                ShellCall.callScript("/opt/ads-ha/ha/shell", "createErrorFile.sh", new ArrayList<String>());
                monitorTimes = Constant.MONITOR_TIMES;
            } else {
                monitorTimes--;
            }
        }
    }

    // 创建单个文件
    public static boolean createFile(String filePath) {
        File file = new File(filePath);
        if (file.exists()) {// 判断文件是否存在
            System.out.println("目标文件已存在" + filePath);
            return false;
        }
        if (filePath.endsWith(File.separator)) {// 判断文件是否为目录
            System.out.println("目标文件不能为目录！");
            return false;
        }
        if (!file.getParentFile().exists()) {// 判断目标文件所在的目录是否存在
            // 如果目标文件所在的文件夹不存在，则创建父文件夹
            System.out.println("目标文件所在目录不存在，准备创建它！");
            if (!file.getParentFile().mkdirs()) {// 判断创建目录是否成功
                System.out.println("创建目标文件所在的目录失败！");
                return false;
            }
        }
        try {
            if (file.createNewFile()) {// 创建目标文件
                System.out.println("创建文件成功:" + filePath);
                return true;
            } else {
                System.out.println("创建文件失败！");
                return false;
            }
        } catch (IOException e) {// 捕获异常
            e.printStackTrace();
            System.out.println("创建文件失败！" + e.getMessage());
            return false;
        }
    }
}
