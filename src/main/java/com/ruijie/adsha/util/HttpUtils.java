package com.ruijie.adsha.util;

import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpEntity;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by hp on 2017/12/18.
 */

@Slf4j
public class HttpUtils {

    /**
     * post方式提交表单（模拟用户登录请求）
     */
    public static void postForm() {
        // 创建默认的httpClient实例.
        CloseableHttpClient httpclient = HttpClients.createDefault();
        // 创建httppost
        HttpPost httppost = new HttpPost("http://localhost:8080/myDemo/Ajax/serivceJ.action");
        // 创建参数队列
        List formparams = new ArrayList();
        formparams.add(new BasicNameValuePair("username", "admin"));
        formparams.add(new BasicNameValuePair("password", "123456"));
        UrlEncodedFormEntity uefEntity;
        try {
            uefEntity = new UrlEncodedFormEntity(formparams, "UTF-8");
            httppost.setEntity(uefEntity);
            System.out.println("executing request " + httppost.getURI());
            CloseableHttpResponse response = httpclient.execute(httppost);
            try {
                HttpEntity entity = response.getEntity();
                if (entity != null) {
                    System.out.println("--------------------------------------");
                    System.out.println("Response content: " + EntityUtils.toString(entity, "UTF-8"));
                    System.out.println("--------------------------------------");
                }
            } finally {
                response.close();
            }
        } catch (ClientProtocolException e) {
            log.error(e.getMessage(), e);
        } catch (UnsupportedEncodingException e1) {
            log.error(e1.getMessage(), e1);
        } catch (IOException e) {
            log.error(e.getMessage(), e);
        } finally {
            // 关闭连接,释放资源
            try {
                httpclient.close();
            } catch (IOException e) {
                log.error(e.getMessage(), e);
            }
        }
    }

    /**
     * 发送 post请求访问本地应用并根据传递参数不同返回不同结果
     */
    public static void post() {
        // 创建默认的httpClient实例.
        CloseableHttpClient httpclient = HttpClients.createDefault();
        // 创建httppost
        HttpPost httppost = new HttpPost("http://localhost:8080/myDemo/Ajax/serivceJ.action");
        // 创建参数队列
        List formparams = new ArrayList();
        formparams.add(new BasicNameValuePair("type", "house"));
        UrlEncodedFormEntity uefEntity;
        try {
            uefEntity = new UrlEncodedFormEntity(formparams, "UTF-8");
            httppost.setEntity(uefEntity);
            System.out.println("executing request " + httppost.getURI());
            CloseableHttpResponse response = httpclient.execute(httppost);
            try {
                HttpEntity entity = response.getEntity();
                if (entity != null) {
                    System.out.println("--------------------------------------");
                    System.out.println("Response content: " + EntityUtils.toString(entity, "UTF-8"));
                    System.out.println("--------------------------------------");
                }
            } finally {
                response.close();
            }
        } catch (ClientProtocolException e) {
            log.error(e.getMessage(), e);
        } catch (UnsupportedEncodingException e1) {
            log.error(e1.getMessage(), e1);
        } catch (IOException e) {
            log.error(e.getMessage(), e);
        } finally {
            // 关闭连接,释放资源
            try {
                httpclient.close();
            } catch (IOException e) {
                log.error(e.getMessage(), e);
            }
        }
    }

    /**
     * 发送 get请求
     */
    public static String get(String url, String params) {
        CloseableHttpClient httpclient = HttpClients.createDefault();
        try {
            //创建httpget
            if (!StringUtils.isEmpty(params)) {
                params = "?" + params;
            }
            HttpGet httpget = new HttpGet(url + params);
            System.out.println("executing request " + httpget.getURI());
            // 执行get请求.
            CloseableHttpResponse response = httpclient.execute(httpget);
            try {
                // 获取响应实体
                HttpEntity entity = response.getEntity();
                if (entity != null) {
                    // 打印响应内容
                    System.out.println("Response content: " + EntityUtils.toString(entity));
                    return EntityUtils.toString(entity);
                }
            }catch (Exception ex) {

            }
        } catch (ClientProtocolException e) {
            log.error(e.getMessage(), e);
        } catch (IOException e) {
            log.error(e.getMessage(), e);
        } finally {
            // 关闭连接,释放资源
            try {
                httpclient.close();
            } catch (IOException e) {
                log.error(e.getMessage(), e);
            }
        }
        return null;
    }
}
