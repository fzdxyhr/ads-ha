package com.ruijie.adsha.service;

import com.ruijie.adsha.constant.ResponseInfo;

import java.util.List;

/**
 * Created by hp on 2017/12/26.
 */
public interface MysqlGroupService {

    boolean install(List<String> ips);

    boolean start(List<String> ips);

    ResponseInfo stop();

    ResponseInfo uninstall();

}
