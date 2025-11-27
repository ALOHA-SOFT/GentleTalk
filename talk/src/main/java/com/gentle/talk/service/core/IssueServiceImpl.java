package com.gentle.talk.service.core;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.Issue;
import com.gentle.talk.domain.users.Users;
import com.gentle.talk.mapper.core.IssueMapper;
import com.gentle.talk.mapper.etc.MediationProposalLogMapper;
import com.gentle.talk.mapper.users.UserMapper;
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

    @Autowired
    UserMapper userMapper;

    @Autowired
    MediationProposalLogMapper mediationProposalLogMapper;

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
        log.info("## 중재안 선택 (최초/재선택 모두 허용) ##");
        log.info("issueNo={}, selectedProposal={}", issueNo, selectedProposal);
        
        try {
            Issue issue = mapper.selectById(issueNo);
            if (issue == null) {
                log.error("이슈를 찾을 수 없습니다. issueNo={}", issueNo);
                return false;
            }

            String prev = issue.getSelectedMediationProposal();
            log.info("기존 선택 중재안: {}", prev);
            
            issue.setSelectedMediationProposal(selectedProposal);

            if (!"중재안제시".equals(issue.getStatus())) {
                issue.setStatus("중재안제시");
            }

            int result = mapper.updateById(issue);
            log.info("중재안 선택/갱신 결과 - result: {}, newSelected={}", result, selectedProposal);
            
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

        String analysisResult = "";
        String negotiationMessage = "";

        try {
            // 1️⃣ 분석 결과 생성 프롬프트 (analysisResult 전용)
            String promptAnalysis = """
                    너는 공감형 협상 코치를 도와주는 AI야.

                    아래 사용자의 갈등 상황과 요구 조건을 바탕으로,
                    상황을 객관적으로 정리한 분석 요약만 작성해줘.

                    [갈등 상황]
                    %s

                    [나의 요구조건]
                    %s

                    반드시 아래 출력 형식을 그대로 따라야 한다.

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
                    - 협상 메시지, 편지 형식, 상대방에게 직접 말 거는 문장은 작성하지 않는다.
                    - 인사말, 결론 문구, "감사합니다" 같은 표현은 쓰지 않는다.
                    - 제목(⚖️ 💬 📚)은 그대로 출력한다.
                    - Markdown 불릿(-)만 사용한다.
                    - 불필요한 설명 없이 리스트만 출력한다.
                    """.formatted(conflict, requirements);

            analysisResult = callOpenAi(promptAnalysis).trim();
            issue.setAnalysisResult(analysisResult);

            // 2️⃣ 협상 메시지 생성 프롬프트 (negotiationMessage 전용)
            String promptNegotiation = """
                    너는 공감형 협상 코치를 도와주는 AI야.

                    아래는 사용자의 갈등 상황을 정리한 분석 결과야.
                    이 분석 결과를 바탕으로, 상대방에게 보낼 정중한 협상 메시지를 작성해줘.

                    [분석 결과(analysisResult)]
                    %s

                    협상 메시지 작성 규칙:
                    - 한국어로 작성한다.
                    - 첫 문장은 안녕하세요. [상대방 이름]님, 으로 시작한다.
                    - 5~8문장 정도의 하나의 메시지로 작성한다.
                    - 상대방을 존중하는 톤으로, 감정적인 비난 없이 쓴다.
                    - I-message(나 중심 표현)를 사용한다. (예: "저는 ~라고 느꼈습니다.")
                    - 나의 요구 조건을 분명하지만 부드럽게 전달한다.
                    - 상대방도 수용할 수 있는 대안이나 제안을 1~2개 포함한다.

                    주의사항:
                    - 불릿(-)이나 번호목록을 사용하지 않는다.
                    - 제목, 섹션명(⚖️, 💬, 📚 등)을 쓰지 않는다.
                    - 분석 내용을 다시 요약하지 말고, 실제로 상대방에게 보내는 편지 형태로만 쓴다.
                    """.formatted(analysisResult);

            negotiationMessage = callOpenAi(promptNegotiation).trim();
            issue.setNegotiationMessage(negotiationMessage);

            issue.setStatus("분석완료");

            // 🔥 분석결과 + 협상메시지 + 상태 한 번에 업데이트
            int updatedRows = mapper.updateAnalysisResult(issue);
            if (updatedRows == 0) {
                throw new IllegalStateException("analysis_result 업데이트 실패. issueNo=" + issueNo);
            }
            return mapper.selectByIssueNo(issueNo);

        } catch (Exception e) {
            log.error("AI 분석 중 오류 발생 issueNo={}", issueNo, e);

            issue.setAnalysisResult("AI 분석 실패: " + e.getMessage());
            issue.setStatus("분석실패");

            mapper.updateAnalysisResult(issue);  // 실패 시 분석 결과/상태만 업데이트
            return issue;
        }
    }

    @SuppressWarnings("unchecked")
    private String callOpenAi(String prompt) {

        WebClient webClient = WebClient.builder()
                .baseUrl("https://api.openai.com/v1/chat/completions")
                .defaultHeader("Authorization", "Bearer " + apiKey)
                .defaultHeader("Content-Type", "application/json")
                .build();

        // ✅ WebClient가 JSON으로 자동 직렬화 하도록 Map으로 요청 바디 생성
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

    public boolean updateOpponent(Long issueNo, String name, String contact) {
        Issue issue = mapper.selectByIssueNo(issueNo);
        if (issue == null) return false;

        issue.setNo(issueNo);
        issue.setOpponentName(name);
        issue.setOpponentContact(contact);

        // 회원인지 확인
        Users opponent = userMapper.findByPhone(contact);
        if (opponent != null) {
            issue.setOpponentUserNo(opponent.getNo());
        }

        // negotiation_message 안의 [상대방 이름] 치환
        String msg = issue.getNegotiationMessage();
        if (msg != null 
            && !msg.isBlank() 
            && msg.contains("[상대방 이름]")
            && name != null 
            && !name.isBlank()) {
            
            String replaced = msg.replace("[상대방 이름]", name);
            issue.setNegotiationMessage(replaced);
        }

        return mapper.updateById(issue) > 0;
    }

    @Override
    @Transactional
    public void linkOpponentIssuesAfterSignup(Users user) {
        String phone = user.getTel();
        if (phone == null || phone.isBlank()) {
            return;
        }

        // 1) opponent_contact = 이 전화번호
        // 2) opponent_user_no IS NULL 인 이슈들만 조회
        List<Issue> list = mapper.selectByOpponentContactWithoutUserNo(phone);

        for (Issue issue : list) {
            issue.setOpponentUserNo(user.getNo());
            mapper.updateById(issue);
        }

        log.info("회원가입 후 opponent 매핑 완료 - userNo={}, affectedIssues={}",
                user.getNo(), list.size());
    }

    @Override
    public List<Issue> selectMyIssues(Long userNo) {
        log.info("## 내가 참여한 이슈 목록 조회 ## userNo={}", userNo);

        List<Issue> asSender = mapper.selectByUserNo(userNo);           // 내가 만든 이슈
        List<Issue> asOpponent = mapper.selectByOpponentUserNo(userNo); // 내가 상대방인 이슈

        // ⚠️ 같은 이슈가 두 번 들어오지 않도록 PK 기준으로 합치기 (no 기준 가정)
        Map<Long, Issue> merged = new java.util.LinkedHashMap<>();

        for (Issue i : asSender) {
            merged.put(i.getNo(), i);
        }
        for (Issue i : asOpponent) {
            merged.putIfAbsent(i.getNo(), i);
        }

        return new java.util.ArrayList<>(merged.values());
    }

}
