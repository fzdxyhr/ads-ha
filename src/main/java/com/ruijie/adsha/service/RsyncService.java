package com.ruijie.adsha.service;

import com.ruijie.adsha.constant.ResponseInfo;

/**
 * Created by hp on 2017/12/26.
 */
public interface RsyncService {

    ResponseInfo install();

    ResponseInfo start();

    ResponseInfo stop();

    ResponseInfo uninstall();

    ResponseInfo config();

}
