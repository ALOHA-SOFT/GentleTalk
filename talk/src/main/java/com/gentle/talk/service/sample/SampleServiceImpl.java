package com.gentle.talk.service.sample;

import org.springframework.stereotype.Service;

import com.gentle.talk.domain.Sample;
import com.gentle.talk.mapper.SampleMapper;
import com.gentle.talk.service.BaseServiceImpl;

import groovy.util.logging.Slf4j;

@Slf4j
@Service
public class SampleServiceImpl extends BaseServiceImpl<Sample, SampleMapper> implements SampleService {

  
}
