package com.ruijie.adsha.service;

import com.ruijie.adsha.constant.ResponseInfo;

import java.util.List;

/**
 * Created by hp on 2017/12/18.
 */


public interface AdsHaService {

    ResponseInfo startHa(String virtualIp, List<String> ips);

    ResponseInfo stopHa();

    boolean validIsConfigMasterGroup();

    ResponseInfo remove();
}
