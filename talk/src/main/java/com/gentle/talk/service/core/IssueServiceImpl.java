package com.gentle.talk.service.core;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
import java.util.Map;
import java.util.Random;

import org.springframework.web.reactive.function.client.WebClient;


@Slf4j
@Service
public class IssueServiceImpl extends BaseServiceImpl<Issue, IssueMapper> implements IssueService {

    @Value("${openai.api-key:}")
    private String apiKey;

    @Value("${openai.model:gpt-4o-mini}")
    private String model;

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

    @Override
    public Issue selectByIssueNo(Long issueNo) {
        log.info("## 이슈 번호로 조회 ##");
        log.info("issueNo={}", issueNo);
        
        return mapper.selectByIssueNo(issueNo);
    }

    @Override
    @Transactional
    public Issue analyzeIssue(Long issueNo) {
        log.info("## AI - 요약 분석 요청 ##");
        log.info("issueNo={}", issueNo);

        Issue issue = mapper.selectByIssueNo(issueNo);
        if (issue == null) {
            throw new IllegalArgumentException("해당 ID의 이슈를 찾을 수 없습니다. issueNo=" + issueNo);
        }

        String conflict = issue.getConflictSituation();
        String requirements = issue.getRequirements();

        if (conflict == null || conflict.isBlank() ||
            requirements == null || requirements.isBlank()) {
            throw new IllegalStateException("conflict_situation 또는 requirements가 비어 있습니다. issueNo=" + issueNo);
        }

        String analysisResult = "";   // ← 기본값 초기화

        try {
            // ----- AI 프롬프트 구성 -----
            String prompt = """
                    아래 두 가지 정보를 바탕으로 갈등 상황을 명확하게 정리된 형태로 분석해 주세요.

                    1) 갈등 상황(conflict_situation):
                    %s

                    2) 요구 조건(requirements):
                    %s

                    아래의 출력 형식을 반드시 그대로 유지해 주세요.

                    출력 형식:
                    ⚖️ 주요 쟁점
                    - 핵심 쟁점 3~5개를 간결하게 불릿 형태로 정리
                    - 문장은 짧고 명확하게
                    - 사례, 원인, 갈등 포인트 중심

                    💬 요구 조건
                    - 사용자의 핵심 요구 2~4가지 정리
                    - 실제 필요 / 원하는 결과 중심으로 요약

                    📚 제시 근거
                    - 근거가 될 수 있는 정보, 상황, 논리를 2~4개 작성
                    - 객관적 자료나 일반적인 기준을 예시로 포함

                    주의사항:
                    - 절대로 다른 문구, 인삿말, 서론을 넣지 않는다.
                    - 제목(⚖️ 💬 📚)은 그대로 출력한다.
                    - Markdown 불릿(-)만 사용한다.
                    - 불필요한 설명 없이 리스트만 출력한다.
                    """.formatted(conflict, requirements);

            // ----- WebClient 호출 -----
            WebClient webClient = WebClient.builder()
                    .baseUrl("https://api.openai.com/v1/chat/completions")
                    .defaultHeader("Authorization", "Bearer " + apiKey)
                    .defaultHeader("Content-Type", "application/json")
                    .build();

            Map<String, Object> requestBody = Map.of(
                    "model", model,
                    "messages", List.of(
                            Map.of("role", "system", "content", "You are a helpful Korean counselor."),
                            Map.of("role", "user", "content", prompt)
                    ),
                    "temperature", 0.3
            );

            Map<String, Object> response = webClient.post()
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
            String content = (String) ((Map<String, Object>) choices.get(0).get("message")).get("content");

            analysisResult = content.trim();

            // 정상 처리
            issue.setStatus("분석완료");

        } catch (Exception e) {
            log.error("AI 분석 중 오류 발생 issueNo={}", issueNo, e);

            issue.setAnalysisResult("AI 분석 실패: " + e.getMessage());
            issue.setStatus("분석실패");
        }

        // 공통: DB 업데이트
        issue.setAnalysisResult(analysisResult);
        
        int updatedRows = mapper.updateAnalysisResult(issue);
        if (updatedRows == 0) {
            throw new IllegalStateException("analysis_result 업데이트 실패. issueNo=" + issueNo);
        }
        return mapper.selectByIssueNo(issueNo);
    }


    
}
