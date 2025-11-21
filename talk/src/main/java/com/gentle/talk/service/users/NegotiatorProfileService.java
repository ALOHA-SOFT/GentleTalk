package com.gentle.talk.service.users;

import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.users.NegotiatorProfile;
import com.gentle.talk.service.BaseService;

import java.util.List;

public interface NegotiatorProfileService extends BaseService<NegotiatorProfile> {

    // 협상가 프로필 등록
    boolean register(NegotiatorProfile entity);

    // 회원 번호로 협상가 프로필 조회
    NegotiatorProfile selectByUserNo(Long userNo);
    
    // 페이징 조회
    PageInfo<NegotiatorProfile> page(QueryParams queryParams);

    // 협상가 프로필 수정
    boolean update(NegotiatorProfile entity);
    
    // 전문 분야로 협상가 목록 조회
    List<NegotiatorProfile> findBySpecialty(String categoryCode);
    
    // 평점 순으로 상위 협상가 조회
    List<NegotiatorProfile> findTopRatedNegotiators(int limit);
    
    // 성공률 순으로 상위 협상가 조회
    List<NegotiatorProfile> findTopSuccessRateNegotiators(int limit);
    
    // 협상가 통계 업데이트 (협상 완료 시 호출)
    boolean updateStatistics(Long profileNo, boolean isSuccess, int resolutionDays);
    
    // 협상가 평점 업데이트 (리뷰 등록 시 호출)
    boolean updateRating(Long profileNo, double newRating);
    
}
