package com.gentle.talk.service.core;

import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.Issue;
import com.gentle.talk.service.BaseService;

import java.util.List;

public interface IssueService extends BaseService<Issue> {

    // 이슈 등록
    boolean register(Issue entity);

    // 이슈 코드로 조회
    Issue selectByIssueCode(String issueCode);
    
    // 회원 번호로 이슈 목록 조회
    List<Issue> selectByUserNo(Long userNo);
    
    // 상대방 회원 번호로 이슈 목록 조회
    List<Issue> selectByOpponentUserNo(Long opponentUserNo);
    
    // 페이징 조회
    PageInfo<Issue> page(QueryParams queryParams);

    // 이슈 수정
    boolean update(Issue entity);
    
    // 상태별 이슈 개수 조회
    int countByStatus(Long userNo, String status);
    
    // 최근 이슈 조회
    List<Issue> selectRecentIssues(Long userNo, int limit);
    
    // 이슈 코드 생성 (중복 확인)
    String generateUniqueIssueCode();
    
    // 중재안 저장
    boolean saveMediationProposals(Long issueNo, String mediationProposals);
    
    // 중재안 선택
    boolean selectMediationProposal(Long issueNo, String selectedProposal);
    
    // 상태 변경
    boolean updateStatus(Long issueNo, String status);

    // 이슈 번호로 조회
    Issue selectByIssueNo(Long issueNo);
 
    // 요약 분석 요청
    Issue analyzeIssue(Long issueNo);
}
