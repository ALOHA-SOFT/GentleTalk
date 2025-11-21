package com.gentle.talk.mapper.etc;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gentle.talk.domain.etc.IssueCategory;

@Mapper
public interface IssueCategoryMapper extends BaseMapper<IssueCategory> {

  // 코드로 조회
  public IssueCategory selectByCode(String code);
  
  // 활성화된 카테고리 목록 조회 (정렬순서대로)
  public List<IssueCategory> selectAllEnabled();
  
  // 모든 카테고리 조회 (정렬순서대로)
  public List<IssueCategory> selectAllOrdered();
  
}
