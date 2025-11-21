package com.gentle.talk.mapper.users;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.users.NegotiatorProfile;

@Mapper
public interface NegotiatorProfileMapper extends BaseMapper<NegotiatorProfile> {

  // 회원 번호로 협상가 프로필 조회
  public NegotiatorProfile selectByUserNo(Long userNo);
  
  // 페이징 조회
  public List<NegotiatorProfile> listWithParams(QueryParams queryParams);
  
  // 전문 분야로 협상가 목록 조회 (JSON 검색)
  public List<NegotiatorProfile> findBySpecialty(String categoryCode);
  
  // 평점 순으로 상위 협상가 조회
  public List<NegotiatorProfile> findTopRatedNegotiators(int limit);
  
  // 성공률 순으로 상위 협상가 조회
  public List<NegotiatorProfile> findTopSuccessRateNegotiators(int limit);
  
}
