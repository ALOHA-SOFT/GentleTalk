package com.gentle.talk.mapper.core;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.FormalNotice;

@Mapper
public interface FormalNoticeMapper extends BaseMapper<FormalNotice> {

  // 내용증명 코드로 조회
  public FormalNotice selectByFormalNoticeCode(String formalNoticeCode);

  // 회원 번호로 내용증명 목록 조회
  public List<FormalNotice> selectByUserNo(Long userNo);
  
  // 상대방 회원 번호로 내용증명 목록 조회
  public List<FormalNotice> selectByOpponentUserNo(Long opponentUserNo);
  
  // 페이징 조회
  public List<FormalNotice> listWithParams(QueryParams queryParams);
  
  // 상태별 내용증명 개수 조회
  public int countByStatus(@Param("userNo") Long userNo, @Param("status") String status);
  
  // 최근 내용증명 조회
  public List<FormalNotice> selectRecentIssues(@Param("userNo") Long userNo, @Param("limit") int limit);

  // 내용증명 번호로 조회
  public FormalNotice selectByFormalNoticeNo(Long formalNoticeNo);

  // 분석 결과 및 상태 업데이트
  public int updateAnalysisResult(FormalNotice formalNotice);

  public int updateStatusAndFlag(@Param("no") Long no, @Param("status") String status, @Param("flag") String flag);


}
