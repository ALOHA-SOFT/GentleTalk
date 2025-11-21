package com.gentle.talk.service.etc;

import com.gentle.talk.domain.etc.IssueCategory;
import com.gentle.talk.service.BaseService;

import java.util.List;

public interface IssueCategoryService extends BaseService<IssueCategory> {

    // 카테고리 등록
    boolean register(IssueCategory entity);

    // 코드로 조회
    IssueCategory selectByCode(String code);
    
    // 활성화된 카테고리 목록 조회
    List<IssueCategory> selectAllEnabled();
    
    // 모든 카테고리 조회
    List<IssueCategory> selectAllOrdered();
    
    // 카테고리 수정
    boolean update(IssueCategory entity);
    
}
