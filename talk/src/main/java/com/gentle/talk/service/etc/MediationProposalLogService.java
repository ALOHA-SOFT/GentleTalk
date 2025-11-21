package com.gentle.talk.service.etc;

import com.gentle.talk.domain.etc.MediationProposalLog;
import com.gentle.talk.service.BaseService;

import java.util.List;

public interface MediationProposalLogService extends BaseService<MediationProposalLog> {

    // 중재안 로그 등록
    boolean register(MediationProposalLog entity);

    // 유사한 중재안 로그 검색
    List<MediationProposalLog> findSimilarLogs(Long categoryNo, String conflictSituationHash, int limit);
    
    // 인기 중재안 로그 조회
    List<MediationProposalLog> findPopularLogs(Long categoryNo, int limit);
    
    // 최근 중재안 로그 조회
    List<MediationProposalLog> findRecentLogs(Long categoryNo, int limit);
    
    // 중재안 로그 수정
    boolean update(MediationProposalLog entity);
    
    // 재사용 횟수 증가
    boolean incrementReuseCount(Long logNo);
    
    // 해시값 생성 (MD5)
    String generateHash(String content);
    
    // 중재안 캐시 조회 또는 생성
    MediationProposalLog getOrCreateProposal(Long categoryNo, String conflictSituation, String requirements);
    
}
