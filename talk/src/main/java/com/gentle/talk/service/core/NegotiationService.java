package com.gentle.talk.service.core;

import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.Negotiation;
import com.gentle.talk.service.BaseService;

import java.util.List;

public interface NegotiationService extends BaseService<Negotiation> {

    // 협상 등록
    boolean register(Negotiation entity);

    // 이슈 번호로 협상 목록 조회
    List<Negotiation> selectByIssueNo(Long issueNo);
    
    // 협상가 번호로 협상 목록 조회
    List<Negotiation> selectByUserNo(Long userNo);
    
    // 페이징 조회
    PageInfo<Negotiation> page(QueryParams queryParams);

    // 협상 수정
    boolean update(Negotiation entity);
    
    // 상태별 협상 개수 조회
    int countByStatus(Long userNo, String status);
    
    // 최근 협상 조회
    List<Negotiation> selectRecentNegotiations(Long userNo, int limit);
    
    // 진행 중인 협상 조회
    List<Negotiation> selectOngoingNegotiations(Long userNo);
    
    // 협상 수락
    boolean acceptNegotiation(Long negotiationNo);
    
    // 협상 체결
    boolean finalizeNegotiation(Long negotiationNo);
    
    // 협상 불발
    boolean rejectNegotiation(Long negotiationNo);
    
    // 상태 변경
    boolean updateStatus(Long negotiationNo, String status);
    
}
