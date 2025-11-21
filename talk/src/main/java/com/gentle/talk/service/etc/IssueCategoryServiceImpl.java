package com.gentle.talk.service.etc;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gentle.talk.domain.etc.IssueCategory;
import com.gentle.talk.mapper.etc.IssueCategoryMapper;
import com.gentle.talk.service.BaseServiceImpl;

import lombok.extern.slf4j.Slf4j;

import java.util.List;

@Slf4j
@Service
public class IssueCategoryServiceImpl extends BaseServiceImpl<IssueCategory, IssueCategoryMapper> implements IssueCategoryService {

    @Autowired
    IssueCategoryMapper mapper;

    @Transactional
    @Override
    public boolean register(IssueCategory entity) {
        log.info("## 카테고리 등록 ##");
        log.info("entity={}", entity);
        
        try {
            // ID(UUID) 체크
            if (entity.getId() == null || entity.getId().isEmpty()) {
                entity.setId(java.util.UUID.randomUUID().toString());
            }
            
            // 초기값 설정
            if (entity.getDisplayOrder() == null) entity.setDisplayOrder(0);
            if (entity.getEnabled() == null) entity.setEnabled(true);
            
            int result = mapper.insert(entity);
            log.info("카테고리 등록 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("카테고리 등록 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public IssueCategory selectByCode(String code) {
        log.info("## 코드로 카테고리 조회 ##");
        log.info("code={}", code);
        
        return mapper.selectByCode(code);
    }

    @Override
    public List<IssueCategory> selectAllEnabled() {
        log.info("## 활성화된 카테고리 목록 조회 ##");
        
        return mapper.selectAllEnabled();
    }

    @Override
    public List<IssueCategory> selectAllOrdered() {
        log.info("## 모든 카테고리 조회 ##");
        
        return mapper.selectAllOrdered();
    }

    @Transactional
    @Override
    public boolean update(IssueCategory entity) {
        log.info("## 카테고리 수정 ##");
        log.info("entity={}", entity);
        
        try {
            int result = mapper.updateById(entity);
            log.info("카테고리 수정 결과 - result: {}", result);
            
            return result > 0;
        } catch (Exception e) {
            log.error("카테고리 수정 중 오류 발생", e);
            return false;
        }
    }
    
}
