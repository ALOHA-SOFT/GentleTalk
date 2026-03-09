package com.gentle.talk.service.core;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.FormalNotice;
import com.gentle.talk.mapper.core.FormalNoticeMapper;
import com.gentle.talk.mapper.users.UserMapper;
import com.gentle.talk.service.BaseServiceImpl;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class FormalNoticeServiceImpl extends BaseServiceImpl<FormalNotice, FormalNoticeMapper>
        implements FormalNoticeService {

    @Value("${openai.api-key:}")
    private String apiKey;

    @Value("${openai.model:gpt-4o-mini}")
    private String model;

    @Autowired
    FormalNoticeMapper mapper;

    @Autowired
    UserMapper userMapper;

    @Transactional
    @Override
    public boolean register(FormalNotice entity) {
        log.info("## 내용증명 등록 ##");
        log.info("entity={}", entity);

        try {
            validate(entity);

            if (entity.getId() == null || entity.getId().isEmpty()) {
                entity.setId(java.util.UUID.randomUUID().toString());
            }

            if (entity.getStatus() == null || entity.getStatus().isEmpty()) {
                entity.setStatus("분석완료");
            }

            if (entity.getFlag() == null || entity.getFlag().isEmpty()) {
                entity.setFlag("N");
            }

            // AI 내용증명 생성
            String previewText = generatePreviewText(entity);
            entity.setPreviewText(previewText);

            log.info("AI 생성 previewText={}", previewText);
            log.info("DB 저장 직전 entity={}", entity);

            int result = mapper.insert(entity);
            log.info("내용증명 등록 결과 - result: {}", result);

            return result > 0;

        } catch (Exception e) {
            log.error("내용증명 등록 오류", e);
            return false;
        }
    }

    @Transactional
    @Override
    public boolean update(FormalNotice entity) {
        log.info("## 내용증명 수정 ##");
        log.info("entity={}", entity);

        try {
            int result = mapper.updateById(entity);
            log.info("내용증명 수정 결과 - result: {}", result);
            return result > 0;
        } catch (Exception e) {
            log.error("내용증명 수정 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public FormalNotice selectByFormalNoticeNo(Long no) {
        log.info("## 내용증명 번호로 조회 ##");
        log.info("no={}", no);
        return mapper.selectById(no);
    }

    @Override
    public FormalNotice selectByFormalNoticeCode(String categoryKey) {
        log.info("## 내용증명 코드로 조회 ##");
        log.info("categoryKey={}", categoryKey);
        return mapper.selectByFormalNoticeCode(categoryKey);
    }

    @Override
    public List<FormalNotice> selectByUserNo(Long userNo) {
        log.info("## 회원 번호로 내용증명 목록 조회 ##");
        log.info("userNo={}", userNo);
        return mapper.selectByUserNo(userNo);
    }

    @Override
    public PageInfo<FormalNotice> page(QueryParams queryParams) {
        log.info("## 내용증명 페이징 조회 ##");
        log.info("queryParams={}", queryParams);

        int page = queryParams.getPage();
        int size = queryParams.getSize();
        PageHelper.startPage(page, size);

        List<FormalNotice> list = mapper.listWithParams(queryParams);
        PageInfo<FormalNotice> pageInfo = new PageInfo<>(list);

        log.info("pageInfo={}", pageInfo);
        return pageInfo;
    }

    @Override
    public int countByStatus(Long userNo, String status) {
        log.info("## 상태별 내용증명 개수 조회 ##");
        log.info("userNo={}, status={}", userNo, status);
        return mapper.countByStatus(userNo, status);
    }

    @Override
    public String generatePreviewText(FormalNotice notice) {
        log.info("## 내용증명 미리보기 생성 ##");
        log.info("notice={}", notice);

        validate(notice);

        String prompt = buildPrompt(notice);
        log.info("생성된 프롬프트={}", prompt);

        String result = callOpenAi(prompt);
        log.info("OpenAI 원본 응답={}", result);

        String cleaned = cleanup(result);
        log.info("정리된 previewText={}", cleaned);

        return cleaned;
    }

    private void validate(FormalNotice n) {
        log.info("## 내용증명 입력값 검증 ##");
        log.info("notice={}", n);

        if (n == null) {
            throw new IllegalArgumentException("요청 바디가 비어있습니다.");
        }

        if (n.getUserNo() == null) {
            throw new IllegalArgumentException("userNo는 필수입니다.");
        }

        if (isBlank(n.getCategoryKey())) {
            throw new IllegalArgumentException("categoryKey는 필수입니다.");
        }

        if (isBlank(n.getSenderName()) ||
                isBlank(n.getSenderPhone()) ||
                isBlank(n.getSenderAddress())) {
            throw new IllegalArgumentException("발신인 정보는 필수입니다.");
        }

        if (isBlank(n.getReceiverName()) ||
                isBlank(n.getReceiverPhone()) ||
                isBlank(n.getReceiverAddress())) {
            throw new IllegalArgumentException("수신인 정보는 필수입니다.");
        }

        log.info("내용증명 입력값 검증 완료");
    }

    private String buildPrompt(FormalNotice notice) {
        log.info("## 내용증명 프롬프트 생성 ##");
        log.info("notice={}", notice);

        String categoryDataText = toPrettyLines(notice.getCategoryData());

        String prompt = """
                너는 한국 법률문서 작성 AI다.

                다음 정보를 기반으로 "내용증명 문서"를 작성하라.

                발신인
                %s
                %s
                %s

                수신인
                %s
                %s
                %s

                카테고리
                %s

                상세 정보
                %s

                문서 형식
                제목: 내용증명
                사건 개요
                경위
                요구사항
                이행기한
                미이행시 조치
                """.formatted(
                notice.getSenderName(),
                notice.getSenderPhone(),
                notice.getSenderAddress(),
                notice.getReceiverName(),
                notice.getReceiverPhone(),
                notice.getReceiverAddress(),
                notice.getCategoryKey(),
                categoryDataText);

        log.info("프롬프트 생성 완료");
        return prompt;
    }

    private String toPrettyLines(Map<String, Object> map) {
        log.info("## categoryData 문자열 변환 ##");
        log.info("categoryData={}", map);

        if (map == null || map.isEmpty()) {
            return "";
        }

        StringBuilder sb = new StringBuilder();

        for (Map.Entry<String, Object> e : map.entrySet()) {
            sb.append(e.getKey())
                    .append(": ")
                    .append(e.getValue())
                    .append("\n");
        }

        String result = sb.toString();
        log.info("변환 결과={}", result);

        return result;
    }

    @SuppressWarnings("unchecked")
    private String callOpenAi(String prompt) {
        log.info("## OpenAI 호출 ##");
        log.info("model={}", model);
        log.info("prompt={}", prompt);

        WebClient webClient = WebClient.builder()
                .baseUrl("https://api.openai.com/v1/chat/completions")
                .defaultHeader("Authorization", "Bearer " + apiKey)
                .defaultHeader("Content-Type", "application/json")
                .build();

        Map<String, Object> requestBody = Map.of(
                "model", model,
                "messages", List.of(
                        Map.of("role", "user", "content", prompt)));

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

        String content = message.get("content").toString();
        log.info("### OpenAI content: {}", content);

        return content;
    }

    private String cleanup(String s) {
        log.info("## 응답 문자열 정리 ##");
        log.info("원본 문자열={}", s);

        if (s == null) {
            return "";
        }

        String cleaned = s.replace("```", "").trim();
        log.info("정리된 문자열={}", cleaned);

        return cleaned;
    }

    private boolean isBlank(String v) {
        return v == null || v.trim().isEmpty();
    }

    @Transactional
    @Override
    public boolean updateStatus(Long formalNoticeNo, String status) {
        log.info("## 내용증명 상태 변경 ##");
        log.info("formalNoticeNo={}, status={}", formalNoticeNo, status);

        try {
            FormalNotice found = mapper.selectById(formalNoticeNo);

            if (found == null) {
                log.error("내용증명을 찾을 수 없습니다. formalNoticeNo={}", formalNoticeNo);
                return false;
            }

            found.setStatus(status);

            if ("발송완료".equals(status)) {
                found.setFlag("Y");
            }

            int result = mapper.updateById(found);
            log.info("내용증명 상태 변경 결과 - result: {}", result);

            return result > 0;
        } catch (Exception e) {
            log.error("내용증명 상태 변경 중 오류 발생", e);
            return false;
        }
    }

    @Transactional
    @Override
    public boolean updateFlag(Long formalNoticeNo, String flag) {
        log.info("## 내용증명 flag 상태 변경 ##");
        log.info("formalNoticeNo={}, flag={}", formalNoticeNo, flag);

        try {
            FormalNotice found = mapper.selectById(formalNoticeNo);

            if (found == null) {
                log.error("내용증명을 찾을 수 없습니다. formalNoticeNo={}", formalNoticeNo);
                return false;
            }

            found.setFlag(flag);

            int result = mapper.updateById(found);
            log.info("내용증명 flag 상태 변경 결과 - result: {}", result);

            return result > 0;
        } catch (Exception e) {
            log.error("내용증명 flag 상태 변경 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public List<FormalNotice> selectByOpponentUserNo(Long opponentUserNo) {
        log.info("## 상대방 회원 번호로 내용증명 목록 조회 ##");
        log.info("opponentUserNo={}", opponentUserNo);
        return mapper.selectByOpponentUserNo(opponentUserNo);
    }

    @Override
    public String generateUniqueFormalNoticeCode() {
        log.info("## 내용증명 코드 생성 ##");

        String code = "FN-" + System.currentTimeMillis();
        log.info("생성된 내용증명 코드={}", code);

        return code;
    }

}