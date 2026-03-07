package com.gentle.talk.service.core;

import java.util.List;

import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.FormalNotice;
import com.gentle.talk.service.BaseService;
import com.github.pagehelper.PageInfo;

public interface FormalNoticeService extends BaseService<FormalNotice> {

    // 내용증명 등록
    boolean register(FormalNotice entity);

    // 내용증명 코드로 조회
    FormalNotice selectByFormalNoticeCode(String formalNoticeCode);

    // 회원 번호로 내용증명 목록 조회
    List<FormalNotice> selectByUserNo(Long userNo);

    // 상대방 회원 번호로 내용증명 목록 조회
    List<FormalNotice> selectByOpponentUserNo(Long opponentUserNo);

    // 페이징 조회
    PageInfo<FormalNotice> page(QueryParams queryParams);

    // 내용증명 수정
    boolean update(FormalNotice entity);
    
    // 상태별 내용증명 개수 조회
    int countByStatus(Long userNo, String status);
    
    // 내용증명 코드 생성 (중복 확인)
    String generateUniqueFormalNoticeCode();
    
    // 상태 변경
    boolean updateStatus(Long formalNoticeNo, String status);

    // 내용증명 번호로 조회
    FormalNotice selectByFormalNoticeNo(Long formalNoticeNo);

    // flag 상태 변경
    boolean updateFlag(Long formalNoticeNo, String flag);

    // 미리보기 텍스트 생성
    String generatePreviewText(FormalNotice formalNotice);

}
