package com.ruijie.adsha.controller;

import com.ruijie.adsha.shell.ShellCall;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
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
public class ScheduledTasks {

    public static String ERR_DIR = "/opt/ads-ha/ha/logs/";

    private static final Logger log = LoggerFactory.getLogger(ScheduledTasks.class);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Scheduled(fixedRate = 5000)
    public void checkMysqlService() {
        StringBuffer sql = new StringBuffer();
        sql.append("select 1");
        try {
            jdbcTemplate.execute(sql.toString());
        } catch (Exception ex) {
            log.error("mysql service fail", ex);
            //数据库服务失败,创建一个错误日志文件
            ShellCall.callScript("/opt/ads-ha/ha/shell", "sqlError.sh", new ArrayList<String>());
            createFile("/opt/ads-ha/ha/shell/");
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
