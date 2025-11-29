package com.gentle.talk.controller.v1;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.gentle.talk.domain.core.Issue;
import com.gentle.talk.service.common.SMSService;
import com.gentle.talk.service.core.IssueService;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;


@Slf4j
@RestController
@RequestMapping("/api/v1/sms")
@Tag(name = "SMS Controller", description = "SMS 관리 API")
public class SMSController {

    @Autowired
    private SMSService smsService;

    @Autowired
    private IssueService issueService;

    /**
     * 문자 보내기 화면
     * @return
     */
    @GetMapping(value="/send")
    public String send() {
        return "index";
    }
    
    /**
     * param
     *  - msg       : 문자메시지
     *  - receiver  : 받는번호1,받는번호2, ...      
     *              ex) 01011112222,01033334444
     * @param param
     * @return
     */
    @PostMapping("/send")
    @ResponseBody
    public String sendSMS(@RequestParam MultiValueMap<String, String> param) {
        log.info("msg : " + param.getFirst("msg"));  
        log.info("receiver : " + param.get("receiver").toString());
        log.info("rdate : " + param.getFirst("rdate"));  
        log.info("rtime : " + param.getFirst("rtime"));  
        log.info("testmode_yn : " + param.getFirst("testmode_yn"));
        
        // ✅ 이슈 번호 받기 (없으면 null)
        String issueNoStr = param.getFirst("issueNo");
        log.info("issueNo : " + issueNoStr);
        Long issueNo = null;
        if (issueNoStr != null && !issueNoStr.isEmpty()) {
            try {
                issueNo = Long.valueOf(issueNoStr);
            } catch (NumberFormatException e) {
                log.warn("잘못된 issueNo 값: {}", issueNoStr);
            }
        }

        // 문자 전송 요청
        Map<String, Object> resultMap = smsService.send(param);
        
        Object resultCode = resultMap.get("result_code");
        Integer result_code = Integer.valueOf( resultCode != null ? resultCode.toString() : "-1" );
        String message = (String) resultMap.get("message");

        // ❌ 전송 실패
        if( result_code == -101 ) {
            log.info("(전송 실패) : " + message);
            return message;
        }

        // ⭕ 전송 성공- 분석완료➡상대방대기
        if (issueNo != null) {
            try {
                issueService.updateStatus(issueNo, "상대방대기");  // 👉 서비스 호출
                issueService.updateFlag(issueNo, "Y");
                log.info("Issue[{}] 상태를 '상대방대기'로 변경 완료", issueNo);
            } catch (Exception e) {
                log.error("Issue[{}] 상태 변경 중 오류", issueNo, e);
            }
        }

        return resultMap.toString();
    }
}