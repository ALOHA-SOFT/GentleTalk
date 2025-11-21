package com.gentle.talk.service.core;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.Negotiation;
import com.gentle.talk.mapper.core.NegotiationMapper;
import com.gentle.talk.service.BaseServiceImpl;

import lombok.extern.slf4j.Slf4j;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
public class NegotiationServiceImpl extends BaseServiceImpl<Negotiation, NegotiationMapper> implements NegotiationService {

    @Autowired
    NegotiationMapper mapper;

    @Transactional
    @Override
    public boolean register(Negotiation entity) {
        log.info("## 협상 등록 ##");
        log.info("entity={}", entity);
        
        try {
            // 초기 상태 설정
            if (entity.getStatus() == null || entity.getStatus().isEmpty()) {
                entity.setStatus("대기");
            }
            
            int result = mapper.insert(entity);
            log.info("협상 등록 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상 등록 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public List<Negotiation> selectByIssueNo(Long issueNo) {
        log.info("## 이슈 번호로 협상 목록 조회 ##");
        log.info("issueNo={}", issueNo);
        
        return mapper.selectByIssueNo(issueNo);
    }

    @Override
    public List<Negotiation> selectByUserNo(Long userNo) {
        log.info("## 협상가 번호로 협상 목록 조회 ##");
        log.info("userNo={}", userNo);
        
        return mapper.selectByUserNo(userNo);
    }

    @Override
    public PageInfo<Negotiation> page(QueryParams queryParams) {
        log.info("## 협상 페이징 조회 ##");
        log.info("queryParams={}", queryParams);
        
        // PageHelper 설정
        int page = queryParams.getPage();
        int size = queryParams.getSize();
        PageHelper.startPage(page, size);
        
        List<Negotiation> list = mapper.listWithParams(queryParams);
        PageInfo<Negotiation> pageInfo = new PageInfo<>(list);
        
        log.info("pageInfo={}", pageInfo);
        return pageInfo;
    }

    @Transactional
    @Override
    public boolean update(Negotiation entity) {
        log.info("## 협상 수정 ##");
        log.info("entity={}", entity);
        
        try {
            int result = mapper.updateById(entity);
            log.info("협상 수정 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상 수정 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public int countByStatus(Long userNo, String status) {
        log.info("## 상태별 협상 개수 조회 ##");
        log.info("userNo={}, status={}", userNo, status);
        
        return mapper.countByStatus(userNo, status);
    }

    @Override
    public List<Negotiation> selectRecentNegotiations(Long userNo, int limit) {
        log.info("## 최근 협상 조회 ##");
        log.info("userNo={}, limit={}", userNo, limit);
        
        return mapper.selectRecentNegotiations(userNo, limit);
    }

    @Override
    public List<Negotiation> selectOngoingNegotiations(Long userNo) {
        log.info("## 진행 중인 협상 조회 ##");
        log.info("userNo={}", userNo);
        
        return mapper.selectOngoingNegotiations(userNo);
    }

    @Transactional
    @Override
    public boolean acceptNegotiation(Long negotiationNo) {
        log.info("## 협상 수락 ##");
        log.info("negotiationNo={}", negotiationNo);
        
        try {
            Negotiation negotiation = mapper.selectById(negotiationNo);
            if (negotiation == null) {
                log.error("협상을 찾을 수 없습니다. negotiationNo={}", negotiationNo);
                return false;
            }
            
            negotiation.setStatus("수락");
            negotiation.setAcceptedAt(LocalDateTime.now());
            
            int result = mapper.updateById(negotiation);
            log.info("협상 수락 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상 수락 중 오류 발생", e);
            return false;
        }
    }

    @Transactional
    @Override
    public boolean finalizeNegotiation(Long negotiationNo) {
        log.info("## 협상 체결 ##");
        log.info("negotiationNo={}", negotiationNo);
        
        try {
            Negotiation negotiation = mapper.selectById(negotiationNo);
            if (negotiation == null) {
                log.error("협상을 찾을 수 없습니다. negotiationNo={}", negotiationNo);
                return false;
            }
            
            negotiation.setStatus("체결");
            negotiation.setFinalizedAt(LocalDateTime.now());
            
            int result = mapper.updateById(negotiation);
            log.info("협상 체결 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상 체결 중 오류 발생", e);
            return false;
        }
    }

    @Transactional
    @Override
    public boolean rejectNegotiation(Long negotiationNo) {
        log.info("## 협상 불발 ##");
        log.info("negotiationNo={}", negotiationNo);
        
        try {
            Negotiation negotiation = mapper.selectById(negotiationNo);
            if (negotiation == null) {
                log.error("협상을 찾을 수 없습니다. negotiationNo={}", negotiationNo);
                return false;
            }
            
            negotiation.setStatus("불발");
            
            int result = mapper.updateById(negotiation);
            log.info("협상 불발 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상 불발 중 오류 발생", e);
            return false;
        }
    }

    @Transactional
    @Override
    public boolean updateStatus(Long negotiationNo, String status) {
        log.info("## 협상 상태 변경 ##");
        log.info("negotiationNo={}, status={}", negotiationNo, status);
        
        try {
            Negotiation negotiation = mapper.selectById(negotiationNo);
            if (negotiation == null) {
                log.error("협상을 찾을 수 없습니다. negotiationNo={}", negotiationNo);
                return false;
            }
            
            negotiation.setStatus(status);
            
            int result = mapper.updateById(negotiation);
            log.info("협상 상태 변경 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상 상태 변경 중 오류 발생", e);
            return false;
        }
    }
    
}
