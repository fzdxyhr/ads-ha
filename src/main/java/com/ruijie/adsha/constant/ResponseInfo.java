package com.ruijie.adsha.constant;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Created by hp on 2017/12/18.
 */

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ResponseInfo {

    //响应状态码
    private int status;
    //返回信息编码
    private String code;
    //返回信息
    private String message;

}
