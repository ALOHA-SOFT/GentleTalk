package com.gentle.talk.service.etc;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gentle.talk.domain.core.Issue;
import com.gentle.talk.domain.etc.MediationProposalLog;
import com.gentle.talk.mapper.core.IssueMapper;
import com.gentle.talk.mapper.etc.MediationProposalLogMapper;
import com.gentle.talk.service.BaseServiceImpl;

import lombok.extern.slf4j.Slf4j;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class MediationProposalLogServiceImpl extends BaseServiceImpl<MediationProposalLog, MediationProposalLogMapper> implements MediationProposalLogService {

    @Autowired
    MediationProposalLogMapper mapper;

    @Autowired
    private IssueMapper issueMapper; 

    @Value("${openai.api-key:}")
    private String apiKey;

    @Value("${openai.model:gpt-4o-mini}")
    private String model;

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

    @Override
    @Transactional
    public MediationProposalLog generateProposalsFromIssue(Long issueNo, Long categoryNo) {
        log.info("## AI - 중재안 생성 요청 (MediationProposalLog) ##");
        log.info("issueNo={}, categoryNo={}", issueNo, categoryNo);

        // 1) Issue에서 필요한 정보 가져오기
        Issue issue = issueMapper.selectByIssueNo(issueNo);
        if (issue == null) {
            throw new IllegalArgumentException("해당 ID의 이슈를 찾을 수 없습니다. issueNo=" + issueNo);
        }

        String analysisResult     = issue.getAnalysisResult();
        String negotiationMessage = issue.getNegotiationMessage();
        String conflictSituation  = issue.getConflictSituation();
        String requirements       = issue.getRequirements();

        if (analysisResult == null || analysisResult.isBlank()) {
            throw new IllegalStateException("analysisResult가 비어 있습니다. issueNo=" + issueNo);
        }
        if (negotiationMessage == null || negotiationMessage.isBlank()) {
            throw new IllegalStateException("negotiationMessage가 비어 있습니다. issueNo=" + issueNo);
        }

        // 🟢 categoryNo 없으면 이슈의 no 사용
        if (categoryNo == null) {
            categoryNo = issue.getNo();
            log.info("categoryNo가 없어 issue.no로 설정됨 → categoryNo={}", categoryNo);
            if (categoryNo == null) {
                throw new IllegalStateException("이슈에 categoryNo(또는 no)가 설정되어 있지 않습니다. issueNo=" + issueNo);
            }
        }

        try {
            // 2) 프롬프트 구성
            String prompt = """
                    너는 중립적인 갈등 조정가야.

                    아래는 한 갈등 상황에 대한 분석 결과(analysisResult)와,
                    사용자가 상대방에게 보내려는 협상 메시지 초안(negotiationMessage)이야.

                    [갈등 상황]
                    %s

                    [나의 요구조건]
                    %s

                    [분석 결과]
                    %s

                    [협상 메시지 초안]
                    %s

                    이 정보를 바탕으로, 서로 수용 가능한 현실적인 중재안을 4개 제시해줘.

                    출력 규칙:
                    - 각 중재안은 한국어 한 문단(줄바꿈 없이)으로 작성한다.
                    - 상대방과 나 모두 받아들일 수 있는 절충안을 제시한다.
                    - 감정 배려, 관계 유지, 실질적인 조건(금액/기간/역할 분담 등)을 균형 있게 포함한다.
                    - 각 항목은 서로 다른 방향의 대안이 되도록 작성한다.
                    - 불릿(-), 번호(1. 2. 3.), 제목은 사용하지 않는다.

                    반드시 아래 형식의 JSON 배열 "문자열"만 응답해야 한다.
                    형식 예시:
                    [
                        "중재안 1 내용...",
                        "중재안 2 내용...",
                        "중재안 3 내용...",
                        "중재안 4 내용..."
                    ]

                    주의사항:
                    - 위 JSON 배열 이외의 설명 문장, 주석, 코드블럭 표시는 절대 쓰지 않는다.
                    - 배열 안에는 정확히 4개의 문자열만 포함한다.
                    """.formatted(
                    conflictSituation != null ? conflictSituation : "",
                    requirements       != null ? requirements       : "",
                    analysisResult,
                    negotiationMessage
            );

            // 3) OpenAI 호출
            String raw = callOpenAi(prompt).trim();
            log.info("### OpenAI 중재안 raw: {}", raw);

            // 3-1) ```json ``` 코드블럭 제거
            String cleaned = cleanMarkdownFence(raw);
            log.info("### OpenAI 중재안 cleaned: {}", cleaned);

            // 3-2) JSON 파싱
            ObjectMapper mapper = new ObjectMapper();
            JsonNode node;
            try {
                node = mapper.readTree(cleaned);
            } catch (Exception je) {
                log.error("OpenAI 응답이 유효한 JSON 이 아닙니다. raw={}", raw, je);
                throw new IllegalStateException("AI 응답이 유효한 JSON 배열이 아닙니다.");
            }

            if (!node.isArray()) {
                log.error("OpenAI 응답이 JSON 배열이 아닙니다. node={}", node);
                throw new IllegalStateException("AI 응답이 JSON 배열이 아닙니다.");
            }

            if (node.size() == 0) {
                throw new IllegalStateException("AI가 생성한 중재안이 비어 있습니다.");
            }

            if (node.size() != 4) {
                log.warn("중재안 개수가 4개가 아닙니다. size={}", node.size());
            }

            // 3-3) issues 테이블에 저장할 전체 JSON 배열
            String proposalsJson = mapper.writeValueAsString(node);
            log.info("### 최종 저장용 중재안 JSON(issues): {}", proposalsJson);

            // 4) mediation_proposal_logs 에는 한 줄당 한 개씩 INSERT
            String hashSource   = conflictSituation != null ? conflictSituation : analysisResult;
            String conflictHash = generateHash(hashSource);
            log.info("생성된 해시값: {}", conflictHash);

            int sequence = 1;
            MediationProposalLog firstLog = null;

            for (JsonNode item : node) {
                if (item == null || item.isNull()) continue;

                String proposalText = item.asText();   // 중재안 한 개 내용

                MediationProposalLog logEntity = new MediationProposalLog();
                logEntity.setId(java.util.UUID.randomUUID().toString());
                logEntity.setCategoryNo(categoryNo);
                logEntity.setConflictSituationHash(conflictHash);
                logEntity.setConflictSituation(conflictSituation);
                logEntity.setRequirements(requirements);

                // 🔥 JSON 컬럼이므로 유효한 JSON 문자열로 인코딩
                logEntity.setMediationProposals(
                        mapper.writeValueAsString(proposalText)  // "\"문장...\"" 형태
                );

                logEntity.setIsFromApi(true);
                logEntity.setReuseCount(0);
                logEntity.setSourceLogNo(null);
                logEntity.setSimilarityScore(1.0);
                logEntity.setIssueNo(issueNo);
                logEntity.setSequence(sequence++);

                log.info("## 중재안 로그 등록 ##");
                log.info("entity={}", logEntity);

                boolean inserted = register(logEntity);
                if (!inserted) {
                    log.error("중재안 로그 등록 중 오류 발생 issueNo={}", issueNo);
                    throw new IllegalStateException("중재안 로그 저장 실패 issueNo=" + issueNo);
                }

                if (firstLog == null) {
                    firstLog = logEntity;
                }
            }

            if (firstLog == null) {
                throw new IllegalStateException("중재안 로그를 하나도 저장하지 못했습니다. issueNo=" + issueNo);
            }

            // 5) issues 테이블에도 전체 JSON 배열 저장 + 상태 변경
            issue.setMediationProposals(proposalsJson);   // JSON 배열 ["...", "...", "...", "..."]
            issueMapper.updateById(issue);

            return firstLog;

        } catch (Exception e) {
            log.error("AI 중재안 생성/로그 저장 중 오류 발생 issueNo={}", issueNo, e);
            throw new RuntimeException("AI 중재안 생성 실패: " + e.getMessage(), e);
        }
    }


    /**
     * ```json ... ``` 같은 마크다운 코드 블럭을 제거해주는 유틸
     */
    private String cleanMarkdownFence(String raw) {
        String result = raw.trim();

        if (result.startsWith("```")) {
            // 첫 줄의 ``` 또는 ```json 제거
            int firstNewline = result.indexOf('\n');
            if (firstNewline > 0) {
                result = result.substring(firstNewline + 1);
            }
            // 마지막 ``` 제거
            int lastFence = result.lastIndexOf("```");
            if (lastFence > 0) {
                result = result.substring(0, lastFence);
            }
            result = result.trim();
        }

        return result;
    }

    @SuppressWarnings("unchecked")
    private String callOpenAi(String prompt) {

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

        log.info("### OpenAI 요청 바디: {}", requestBody);

        Map<String, Object> response = webClient.post()
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        log.info("### OpenAI 응답: {}", response);

        if (response == null || !response.containsKey("choices")) {
            throw new IllegalStateException("OpenAI 응답이 비어있거나 choices가 없습니다.");
        }

        List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
        if (choices == null || choices.isEmpty()) {
            throw new IllegalStateException("OpenAI 응답 choices가 비어 있습니다.");
        }

        Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
        if (message == null || message.get("content") == null) {
            throw new IllegalStateException("OpenAI 응답에 message.content가 없습니다.");
        }

        String content = (String) message.get("content");
        log.info("### OpenAI content: {}", content);
        return content;
    }

    
}
