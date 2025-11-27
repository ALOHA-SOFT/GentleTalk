package com.gentle.talk.mapper.core;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.Issue;

@Mapper
public interface IssueMapper extends BaseMapper<Issue> {

  // 이슈 코드로 조회
  public Issue selectByIssueCode(String issueCode);
  
  // 회원 번호로 이슈 목록 조회
  public List<Issue> selectByUserNo(Long userNo);
  
  // 상대방 회원 번호로 이슈 목록 조회
  public List<Issue> selectByOpponentUserNo(Long opponentUserNo);
  
  // 페이징 조회
  public List<Issue> listWithParams(QueryParams queryParams);
  
  // 상태별 이슈 개수 조회
  public int countByStatus(@Param("userNo") Long userNo, @Param("status") String status);
  
  // 최근 이슈 조회
  public List<Issue> selectRecentIssues(@Param("userNo") Long userNo, @Param("limit") int limit);

  // 이슈 번호로 조회
  public Issue selectByIssueNo(Long issueNo);

  // 분석 결과 및 상태 업데이트
  public int updateAnalysisResult(Issue issue);

  // 이슈 테이블에 상대방 정보 매칭
  public List<Issue> selectByOpponentContactWithoutUserNo(@Param("phone") String phone);
  
}
