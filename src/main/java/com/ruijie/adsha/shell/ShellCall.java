package com.ruijie.adsha.shell;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.LinkedList;
import java.util.List;

/**
 * Created by YHR on 2017/12/17.
 */
public class ShellCall {

    public static final String COMMON_SHELL_PATH = "/opt/ads-ha/WEB-INF/classes/ha/shell/";

    public static final String COMMON_SHELL_LOG_PATH = "/opt/ads-ha/WEB-INF/classes/ha/shell/";


    public static int callScript(String shellPath, String shellName, List<String> params) {
        try {
            List<String> commandList = new LinkedList<>();
            if (!shellPath.endsWith("/")) {
                shellPath = shellPath + "/";
            }
            commandList.add(shellPath + shellName);
            //添加参数
            for (String param : params) {
                commandList.add(param);
            }
            String[] commands = new String[commandList.size()];
            for (int i = 0; i < commandList.size(); i++) {
                commands[i] = commandList.get(i);
            }
            Process process = Runtime.getRuntime().exec(commands);
            int exitValue = process.waitFor();
            BufferedReader input = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = input.readLine()) != null) {
                System.out.println("----------------------input--------------------------");
                System.out.println(line);
                System.out.println("----------------------input--------------------------");
            }
            BufferedReader errorInput = new BufferedReader(new InputStreamReader(process.getErrorStream()));
            String errorLine;
            while ((errorLine = errorInput.readLine()) != null) {
                System.out.println("----------------------error--------------------------");
                System.out.println("error:" + errorLine);
                System.out.println("----------------------error--------------------------");
            }
            errorInput.close();
            input.close();
            return exitValue;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 500;
    }

    public static int callScript(String command) {
        try {
            Process process = Runtime.getRuntime().exec(command);
            int exitValue = process.waitFor();
            BufferedReader input = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = input.readLine()) != null) {
                System.out.println("----------------------input--------------------------");
                System.out.println(line);
                System.out.println("----------------------input--------------------------");
            }
            BufferedReader errorInput = new BufferedReader(new InputStreamReader(process.getErrorStream()));
            String errorLine;
            while ((errorLine = errorInput.readLine()) != null) {
                System.out.println("----------------------error--------------------------");
                System.out.println("error:" + errorLine);
                System.out.println("----------------------error--------------------------");
            }
            errorInput.close();
            input.close();
            return exitValue;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 500;
    }

    public static String callScriptString(String command) {
        try {
            StringBuffer result = new StringBuffer();
            Process process = Runtime.getRuntime().exec(command);
            BufferedReader input = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = input.readLine()) != null) {
                System.out.println(line);
                result.append(line);
            }
            input.close();
            return result.toString();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
