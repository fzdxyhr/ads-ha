package com.ruijie.adsha.service;

import com.ruijie.adsha.constant.ResponseInfo;

import java.util.List;

/**
 * Created by hp on 2017/12/26.
 */
public interface MysqlGroupService {

    ResponseInfo install(List<String> ips);

    ResponseInfo start(List<String> ips);

    ResponseInfo stop();

    ResponseInfo uninstall();

}
