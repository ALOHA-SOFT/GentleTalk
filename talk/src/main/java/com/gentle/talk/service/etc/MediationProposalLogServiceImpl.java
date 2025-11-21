package com.gentle.talk.service.etc;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gentle.talk.domain.etc.MediationProposalLog;
import com.gentle.talk.mapper.etc.MediationProposalLogMapper;
import com.gentle.talk.service.BaseServiceImpl;

import lombok.extern.slf4j.Slf4j;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;

@Slf4j
@Service
public class MediationProposalLogServiceImpl extends BaseServiceImpl<MediationProposalLog, MediationProposalLogMapper> implements MediationProposalLogService {

    @Autowired
    MediationProposalLogMapper mapper;

    @Transactional
    @Override
    public boolean register(MediationProposalLog entity) {
        log.info("## 중재안 로그 등록 ##");
        log.info("entity={}", entity);
        
        try {
            // ID(UUID) 체크
            if (entity.getId() == null || entity.getId().isEmpty()) {
                entity.setId(java.util.UUID.randomUUID().toString());
            }
            
            // 해시값 생성
            if (entity.getConflictSituationHash() == null || entity.getConflictSituationHash().isEmpty()) {
                entity.setConflictSituationHash(generateHash(entity.getConflictSituation()));
            }
            
            // 초기값 설정
            if (entity.getReuseCount() == null) entity.setReuseCount(0);
            if (entity.getIsFromApi() == null) entity.setIsFromApi(true);
            
            int result = mapper.insert(entity);
            log.info("중재안 로그 등록 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("중재안 로그 등록 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public List<MediationProposalLog> findSimilarLogs(Long categoryNo, String conflictSituationHash, int limit) {
        log.info("## 유사한 중재안 로그 검색 ##");
        log.info("categoryNo={}, hash={}, limit={}", categoryNo, conflictSituationHash, limit);
        
        return mapper.findSimilarLogs(categoryNo, conflictSituationHash, limit);
    }

    @Override
    public List<MediationProposalLog> findPopularLogs(Long categoryNo, int limit) {
        log.info("## 인기 중재안 로그 조회 ##");
        log.info("categoryNo={}, limit={}", categoryNo, limit);
        
        return mapper.findPopularLogs(categoryNo, limit);
    }

    @Override
    public List<MediationProposalLog> findRecentLogs(Long categoryNo, int limit) {
        log.info("## 최근 중재안 로그 조회 ##");
        log.info("categoryNo={}, limit={}", categoryNo, limit);
        
        return mapper.findRecentLogs(categoryNo, limit);
    }

    @Transactional
    @Override
    public boolean update(MediationProposalLog entity) {
        log.info("## 중재안 로그 수정 ##");
        log.info("entity={}", entity);
        
        try {
            int result = mapper.updateById(entity);
            log.info("중재안 로그 수정 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("중재안 로그 수정 중 오류 발생", e);
            return false;
        }
    }

    @Transactional
    @Override
    public boolean incrementReuseCount(Long logNo) {
        log.info("## 재사용 횟수 증가 ##");
        log.info("logNo={}", logNo);
        
        try {
            int result = mapper.incrementReuseCount(logNo);
            log.info("재사용 횟수 증가 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("재사용 횟수 증가 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public String generateHash(String content) {
        log.info("## 해시값 생성 ##");
        
        try {
            MessageDigest digest = MessageDigest.getInstance("MD5");
            byte[] hash = digest.digest(content.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            
            String hashValue = hexString.toString();
            log.info("생성된 해시값: {}", hashValue);
            
            return hashValue;
        } catch (Exception e) {
            log.error("해시값 생성 중 오류 발생", e);
            return null;
        }
    }

    @Override
    public MediationProposalLog getOrCreateProposal(Long categoryNo, String conflictSituation, String requirements) {
        log.info("## 중재안 캐시 조회 또는 생성 ##");
        log.info("categoryNo={}", categoryNo);
        
        // 1. 해시값 생성
        String hash = generateHash(conflictSituation);
        
        // 2. 유사한 로그 검색
        List<MediationProposalLog> similarLogs = findSimilarLogs(categoryNo, hash, 1);
        
        if (similarLogs != null && !similarLogs.isEmpty()) {
            // 3. 캐시 히트 - 기존 로그 재사용
            MediationProposalLog existingLog = similarLogs.get(0);
            log.info("캐시 히트! 기존 로그 재사용 - logNo: {}", existingLog.getNo());
            
            // 재사용 횟수 증가
            incrementReuseCount(existingLog.getNo());
            
            // 재사용 로그 생성 (원본 참조)
            MediationProposalLog reusedLog = new MediationProposalLog();
            reusedLog.setId(java.util.UUID.randomUUID().toString());
            reusedLog.setCategoryNo(categoryNo);
            reusedLog.setConflictSituationHash(hash);
            reusedLog.setConflictSituation(conflictSituation);
            reusedLog.setRequirements(requirements);
            reusedLog.setMediationProposals(existingLog.getMediationProposals());
            reusedLog.setIsFromApi(false);
            reusedLog.setSourceLogNo(existingLog.getNo());
            reusedLog.setSimilarityScore(1.0); // 동일 해시값이므로 100%
            
            register(reusedLog);
            
            return reusedLog;
        } else {
            // 4. 캐시 미스 - 새로운 로그 필요 (AI API 호출 필요)
            log.info("캐시 미스! AI API 호출 필요");
            return null; // 실제 구현 시 AI API 호출 후 로그 생성
        }
    }
    
}
