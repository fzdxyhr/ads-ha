package com.ruijie.adsha.service;

/**
 * Created by hp on 2017/12/26.
 */
public interface KeepalivedService {

    boolean install();

    boolean start();

    boolean stop();

    boolean uninstall();

    boolean config();

}
