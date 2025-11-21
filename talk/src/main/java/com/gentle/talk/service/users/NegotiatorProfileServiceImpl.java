package com.gentle.talk.service.users;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.users.NegotiatorProfile;
import com.gentle.talk.mapper.users.NegotiatorProfileMapper;
import com.gentle.talk.service.BaseServiceImpl;

import lombok.extern.slf4j.Slf4j;

import java.util.List;

@Slf4j
@Service
public class NegotiatorProfileServiceImpl extends BaseServiceImpl<NegotiatorProfile, NegotiatorProfileMapper> implements NegotiatorProfileService {

    @Autowired
    NegotiatorProfileMapper mapper;

    @Transactional
    @Override
    public boolean register(NegotiatorProfile entity) {
        log.info("## 협상가 프로필 등록 ##");
        log.info("entity={}", entity);
        
        try {
            // ID(UUID) 체크
            if (entity.getId() == null || entity.getId().isEmpty()) {
                entity.setId(java.util.UUID.randomUUID().toString());
            }
            
            // 초기값 설정
            if (entity.getCareerYears() == null) entity.setCareerYears(0);
            if (entity.getTotalCases() == null) entity.setTotalCases(0);
            if (entity.getSuccessCases() == null) entity.setSuccessCases(0);
            if (entity.getSuccessRate() == null) entity.setSuccessRate(0.0);
            if (entity.getAvgResolutionDays() == null) entity.setAvgResolutionDays(0.0);
            if (entity.getRatingAvg() == null) entity.setRatingAvg(0.0);
            if (entity.getRatingCount() == null) entity.setRatingCount(0);
            if (entity.getEnabled() == null) entity.setEnabled(true);
            
            int result = mapper.insert(entity);
            log.info("협상가 프로필 등록 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상가 프로필 등록 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public NegotiatorProfile selectByUserNo(Long userNo) {
        log.info("## 회원 번호로 협상가 프로필 조회 ##");
        log.info("userNo={}", userNo);
        
        return mapper.selectByUserNo(userNo);
    }

    @Override
    public PageInfo<NegotiatorProfile> page(QueryParams queryParams) {
        log.info("## 협상가 프로필 페이징 조회 ##");
        log.info("queryParams={}", queryParams);
        
        // PageHelper 설정
        int page = queryParams.getPage();
        int size = queryParams.getSize();
        PageHelper.startPage(page, size);
        
        List<NegotiatorProfile> list = mapper.listWithParams(queryParams);
        PageInfo<NegotiatorProfile> pageInfo = new PageInfo<>(list);
        
        log.info("pageInfo={}", pageInfo);
        return pageInfo;
    }

    @Transactional
    @Override
    public boolean update(NegotiatorProfile entity) {
        log.info("## 협상가 프로필 수정 ##");
        log.info("entity={}", entity);
        
        try {
            int result = mapper.updateById(entity);
            log.info("협상가 프로필 수정 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상가 프로필 수정 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public List<NegotiatorProfile> findBySpecialty(String categoryCode) {
        log.info("## 전문 분야로 협상가 조회 ##");
        log.info("categoryCode={}", categoryCode);
        
        return mapper.findBySpecialty(categoryCode);
    }

    @Override
    public List<NegotiatorProfile> findTopRatedNegotiators(int limit) {
        log.info("## 평점 순으로 상위 협상가 조회 ##");
        log.info("limit={}", limit);
        
        return mapper.findTopRatedNegotiators(limit);
    }

    @Override
    public List<NegotiatorProfile> findTopSuccessRateNegotiators(int limit) {
        log.info("## 성공률 순으로 상위 협상가 조회 ##");
        log.info("limit={}", limit);
        
        return mapper.findTopSuccessRateNegotiators(limit);
    }

    @Transactional
    @Override
    public boolean updateStatistics(Long profileNo, boolean isSuccess, int resolutionDays) {
        log.info("## 협상가 통계 업데이트 ##");
        log.info("profileNo={}, isSuccess={}, resolutionDays={}", profileNo, isSuccess, resolutionDays);
        
        try {
            NegotiatorProfile profile = mapper.selectById(profileNo);
            if (profile == null) {
                log.error("협상가 프로필을 찾을 수 없습니다. profileNo={}", profileNo);
                return false;
            }
            
            // 총 처리 건수 증가
            profile.setTotalCases(profile.getTotalCases() + 1);
            
            // 성공 건수 증가
            if (isSuccess) {
                profile.setSuccessCases(profile.getSuccessCases() + 1);
            }
            
            // 성공률 계산
            double successRate = (double) profile.getSuccessCases() / profile.getTotalCases() * 100;
            profile.setSuccessRate(Math.round(successRate * 100.0) / 100.0); // 소수점 2자리
            
            // 평균 해결 소요일 계산
            double currentAvg = profile.getAvgResolutionDays();
            int totalCases = profile.getTotalCases();
            double newAvg = ((currentAvg * (totalCases - 1)) + resolutionDays) / totalCases;
            profile.setAvgResolutionDays(Math.round(newAvg * 100.0) / 100.0); // 소수점 2자리
            
            int result = mapper.updateById(profile);
            log.info("협상가 통계 업데이트 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상가 통계 업데이트 중 오류 발생", e);
            return false;
        }
    }

    @Transactional
    @Override
    public boolean updateRating(Long profileNo, double newRating) {
        log.info("## 협상가 평점 업데이트 ##");
        log.info("profileNo={}, newRating={}", profileNo, newRating);
        
        try {
            NegotiatorProfile profile = mapper.selectById(profileNo);
            if (profile == null) {
                log.error("협상가 프로필을 찾을 수 없습니다. profileNo={}", profileNo);
                return false;
            }
            
            // 평가 건수 증가
            int newCount = profile.getRatingCount() + 1;
            profile.setRatingCount(newCount);
            
            // 평균 평점 계산
            double currentAvg = profile.getRatingAvg();
            double newAvg = ((currentAvg * (newCount - 1)) + newRating) / newCount;
            profile.setRatingAvg(Math.round(newAvg * 100.0) / 100.0); // 소수점 2자리
            
            int result = mapper.updateById(profile);
            log.info("협상가 평점 업데이트 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("협상가 평점 업데이트 중 오류 발생", e);
            return false;
        }
    }
    
}
