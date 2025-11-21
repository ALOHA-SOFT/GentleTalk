package com.gentle.talk.mapper.etc;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gentle.talk.domain.etc.MediationProposalLog;

@Mapper
public interface MediationProposalLogMapper extends BaseMapper<MediationProposalLog> {

  // 유사한 중재안 로그 검색 (해시값 기반)
  public List<MediationProposalLog> findSimilarLogs(
      @Param("categoryNo") Long categoryNo,
      @Param("conflictSituationHash") String conflictSituationHash,
      @Param("limit") int limit
  );
  
  // 인기 중재안 로그 조회 (재사용 횟수 기준)
  public List<MediationProposalLog> findPopularLogs(
      @Param("categoryNo") Long categoryNo,
      @Param("limit") int limit
  );
  
  // 최근 중재안 로그 조회
  public List<MediationProposalLog> findRecentLogs(
      @Param("categoryNo") Long categoryNo,
      @Param("limit") int limit
  );
  
  // 재사용 횟수 증가
  public int incrementReuseCount(Long logNo);
  
}
