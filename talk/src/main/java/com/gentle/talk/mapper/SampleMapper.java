package com.gentle.talk.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gentle.talk.domain.Sample;

@Mapper
public interface SampleMapper extends BaseMapper<Sample> {
  
  
}
