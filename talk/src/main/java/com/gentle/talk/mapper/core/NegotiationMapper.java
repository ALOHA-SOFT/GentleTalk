package com.gentle.talk.mapper.core;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.Negotiation;

@Mapper
public interface NegotiationMapper extends BaseMapper<Negotiation> {

  // 이슈 번호로 협상 목록 조회
  public List<Negotiation> selectByIssueNo(Long issueNo);
  
  // 협상가 번호로 협상 목록 조회
  public List<Negotiation> selectByUserNo(Long userNo);
  
  // 페이징 조회
  public List<Negotiation> listWithParams(QueryParams queryParams);
  
  // 상태별 협상 개수 조회
  public int countByStatus(@Param("userNo") Long userNo, @Param("status") String status);
  
  // 최근 협상 조회
  public List<Negotiation> selectRecentNegotiations(@Param("userNo") Long userNo, @Param("limit") int limit);
  
  // 진행 중인 협상 조회
  public List<Negotiation> selectOngoingNegotiations(Long userNo);
  
}
