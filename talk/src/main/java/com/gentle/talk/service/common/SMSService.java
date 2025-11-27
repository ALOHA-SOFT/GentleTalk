package com.gentle.talk.service.common;

import java.util.Map;

import org.springframework.util.MultiValueMap;

public interface SMSService {

    // 문자 보내기
    public Map<String, Object> send(MultiValueMap<String, String> param);
}
