package com.gentle.talk.service.core;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.Issue;
import com.gentle.talk.mapper.core.IssueMapper;
import com.gentle.talk.service.BaseServiceImpl;

import lombok.extern.slf4j.Slf4j;

import java.util.List;
import java.util.Random;

@Slf4j
@Service
public class IssueServiceImpl extends BaseServiceImpl<Issue, IssueMapper> implements IssueService {

    @Autowired
    IssueMapper mapper;

    @Transactional
    @Override
    public boolean register(Issue entity) {
        log.info("## 이슈 등록 ##");
        log.info("entity={}", entity);
        
        try {
            // ID(UUID) 체크
            if (entity.getId() == null || entity.getId().isEmpty()) {
                entity.setId(java.util.UUID.randomUUID().toString());
            }
            
            // 이슈 코드 생성
            if (entity.getIssueCode() == null || entity.getIssueCode().isEmpty()) {
                entity.setIssueCode(generateUniqueIssueCode());
            }
            
            // 초기 상태 설정
            if (entity.getStatus() == null || entity.getStatus().isEmpty()) {
                entity.setStatus("대기");
            }
            
            int result = mapper.insert(entity);
            log.info("이슈 등록 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("이슈 등록 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public Issue selectByIssueCode(String issueCode) {
        log.info("## 이슈 코드로 조회 ##");
        log.info("issueCode={}", issueCode);
        
        return mapper.selectByIssueCode(issueCode);
    }

    @Override
    public List<Issue> selectByUserNo(Long userNo) {
        log.info("## 회원 번호로 이슈 목록 조회 ##");
        log.info("userNo={}", userNo);
        
        return mapper.selectByUserNo(userNo);
    }

    @Override
    public List<Issue> selectByOpponentUserNo(Long opponentUserNo) {
        log.info("## 상대방 회원 번호로 이슈 목록 조회 ##");
        log.info("opponentUserNo={}", opponentUserNo);
        
        return mapper.selectByOpponentUserNo(opponentUserNo);
    }

    @Override
    public PageInfo<Issue> page(QueryParams queryParams) {
        log.info("## 이슈 페이징 조회 ##");
        log.info("queryParams={}", queryParams);
        
        // PageHelper 설정
        int page = queryParams.getPage();
        int size = queryParams.getSize();
        PageHelper.startPage(page, size);
        
        List<Issue> list = mapper.listWithParams(queryParams);
        PageInfo<Issue> pageInfo = new PageInfo<>(list);
        
        log.info("pageInfo={}", pageInfo);
        return pageInfo;
    }

    @Transactional
    @Override
    public boolean update(Issue entity) {
        log.info("## 이슈 수정 ##");
        log.info("entity={}", entity);
        
        try {
            int result = mapper.updateById(entity);
            log.info("이슈 수정 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("이슈 수정 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public int countByStatus(Long userNo, String status) {
        log.info("## 상태별 이슈 개수 조회 ##");
        log.info("userNo={}, status={}", userNo, status);
        
        return mapper.countByStatus(userNo, status);
    }

    @Override
    public List<Issue> selectRecentIssues(Long userNo, int limit) {
        log.info("## 최근 이슈 조회 ##");
        log.info("userNo={}, limit={}", userNo, limit);
        
        return mapper.selectRecentIssues(userNo, limit);
    }

    @Override
    public String generateUniqueIssueCode() {
        log.info("## 이슈 코드 생성 ##");
        
        String issueCode;
        int attempts = 0;
        int maxAttempts = 10;
        
        do {
            // 6자리 랜덤 코드 생성 (영문대문자 + 숫자)
            String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            Random random = new Random();
            StringBuilder sb = new StringBuilder(6);
            
            for (int i = 0; i < 6; i++) {
                sb.append(characters.charAt(random.nextInt(characters.length())));
            }
            
            issueCode = sb.toString();
            attempts++;
            
            // 중복 확인
            Issue existingIssue = mapper.selectByIssueCode(issueCode);
            if (existingIssue == null) {
                log.info("생성된 이슈 코드: {}", issueCode);
                return issueCode;
            }
            
        } while (attempts < maxAttempts);
        
        // 최대 시도 횟수 초과 시 UUID 사용
        log.warn("이슈 코드 생성 실패, UUID 사용");
        return java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    @Transactional
    @Override
    public boolean saveMediationProposals(Long issueNo, String mediationProposals) {
        log.info("## 중재안 저장 ##");
        log.info("issueNo={}, mediationProposals={}", issueNo, mediationProposals);
        
        try {
            Issue issue = mapper.selectById(issueNo);
            if (issue == null) {
                log.error("이슈를 찾을 수 없습니다. issueNo={}", issueNo);
                return false;
            }
            
            issue.setMediationProposals(mediationProposals);
            issue.setStatus("중재안제시");
            
            int result = mapper.updateById(issue);
            log.info("중재안 저장 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("중재안 저장 중 오류 발생", e);
            return false;
        }
    }

    @Transactional
    @Override
    public boolean selectMediationProposal(Long issueNo, String selectedProposal) {
        log.info("## 중재안 선택 ##");
        log.info("issueNo={}, selectedProposal={}", issueNo, selectedProposal);
        
        try {
            Issue issue = mapper.selectById(issueNo);
            if (issue == null) {
                log.error("이슈를 찾을 수 없습니다. issueNo={}", issueNo);
                return false;
            }
            
            issue.setSelectedMediationProposal(selectedProposal);
            issue.setStatus("협상완료");
            
            int result = mapper.updateById(issue);
            log.info("중재안 선택 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("중재안 선택 중 오류 발생", e);
            return false;
        }
    }

    @Transactional
    @Override
    public boolean updateStatus(Long issueNo, String status) {
        log.info("## 이슈 상태 변경 ##");
        log.info("issueNo={}, status={}", issueNo, status);
        
        try {
            Issue issue = mapper.selectById(issueNo);
            if (issue == null) {
                log.error("이슈를 찾을 수 없습니다. issueNo={}", issueNo);
                return false;
            }
            
            issue.setStatus(status);
            
            int result = mapper.updateById(issue);
            log.info("이슈 상태 변경 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("이슈 상태 변경 중 오류 발생", e);
            return false;
        }
    }
    
}
