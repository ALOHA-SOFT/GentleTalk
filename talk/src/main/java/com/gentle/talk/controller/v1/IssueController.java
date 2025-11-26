package com.gentle.talk.controller.v1;

import com.gentle.talk.domain.core.Issue;
import com.gentle.talk.domain.users.Users;
import com.gentle.talk.service.core.IssueService;
import com.gentle.talk.service.users.UserService;
import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.security.core.Authentication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/issues")
@RequiredArgsConstructor
@Tag(name = "이슈 API", description = "협상 이슈 관리 API")
public class IssueController {

    private final IssueService issueService;
    private final UserService userService;

    @PostMapping
    @Operation(summary = "이슈 등록", description = "새로운 협상 이슈를 등록합니다")
    public ResponseEntity<?> register(@RequestBody Issue issue, Authentication authentication) {
        log.info("## 이슈 등록 요청 ##");
        log.info("issue={}", issue);

        String username = authentication.getName();
        Users user = userService.selectByUsername(username);

        issue.setUserNo(user.getNo());
        // Not Null 필드 기본 값 설정
        issue.setOpponentName(" ");
        issue.setOpponentContact(" ");
        // issue_code 비어 있으면 자동 생성
        if (issue.getIssueCode() == null || issue.getIssueCode().isBlank()) {
                issue.setIssueCode(generateIssueCode());
        }
        
        try {
            boolean result = issueService.register(issue);
            if (result) {
                return ResponseEntity.ok().body(issue);
            } else {
                return ResponseEntity.badRequest().body("이슈 등록 실패");
            }
        } catch (Exception e) {
            log.error("이슈 등록 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    private String generateIssueCode() {
    // 형식은 원하는 대로: 날짜 + 시퀀스, UUID 등
    return "ISSUE-" + System.currentTimeMillis();
    }

    @GetMapping("/{no}")
    @Operation(summary = "이슈 조회", description = "이슈 번호로 이슈를 조회합니다")
    public ResponseEntity<?> getIssue(@PathVariable Long no) {
        log.info("## 이슈 조회 ##");
        log.info("no={}", no);

        try {
            Issue issue = issueService.selectByIssueNo(no);
            if (issue != null) {
                return ResponseEntity.ok(issue);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("이슈 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/code/{issueCode}")
    @Operation(summary = "이슈 코드로 조회", description = "이슈 코드로 이슈를 조회합니다")
    public ResponseEntity<?> getIssueByCode(@PathVariable String issueCode) {
        log.info("## 이슈 코드로 조회 ##");
        log.info("issueCode={}", issueCode);

        try {
            Issue issue = issueService.selectByIssueCode(issueCode);
            if (issue != null) {
                return ResponseEntity.ok(issue);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("이슈 코드 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    // @GetMapping("/user/{userNo}")
    // @Operation(summary = "회원의 이슈 목록", description = "회원이 등록한 이슈 목록을 조회합니다")
    // public ResponseEntity<?> getIssuesByUserNo(@PathVariable Long userNo) {
    //     log.info("## 회원의 이슈 목록 조회 ##");
    //     log.info("userNo={}", userNo);

    //     try {
    //         List<Issue> issues = issueService.selectByUserNo(userNo);
    //         return ResponseEntity.ok(issues);
    //     } catch (Exception e) {
    //         log.error("회원 이슈 목록 조회 중 오류 발생", e);
    //         return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
    //     }
    // }

    @GetMapping
    @Operation(summary = "이슈 목록 조회", description = "페이징된 이슈 목록을 조회합니다")
    public ResponseEntity<?> getIssues(QueryParams queryParams) {
        log.info("## 이슈 목록 조회 ##");
        log.info("queryParams={}", queryParams);

        try {
            PageInfo<Issue> pageInfo = issueService.page(queryParams);
            return ResponseEntity.ok(pageInfo);
        } catch (Exception e) {
            log.error("이슈 목록 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/recent/{userNo}")
    @Operation(summary = "최근 이슈", description = "회원의 최근 이슈를 조회합니다")
    public ResponseEntity<?> getRecentIssues(@PathVariable Long userNo, @RequestParam(defaultValue = "5") int limit) {
        log.info("## 최근 이슈 조회 ##");
        log.info("userNo={}, limit={}", userNo, limit);

        try {
            List<Issue> issues = issueService.selectRecentIssues(userNo, limit);
            return ResponseEntity.ok(issues);
        } catch (Exception e) {
            log.error("최근 이슈 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/count/{userNo}")
    @Operation(summary = "상태별 이슈 개수", description = "회원의 상태별 이슈 개수를 조회합니다")
    public ResponseEntity<?> countByStatus(@PathVariable Long userNo, @RequestParam(required = false) String status) {
        log.info("## 상태별 이슈 개수 조회 ##");
        log.info("userNo={}, status={}", userNo, status);

        try {
            int count = issueService.countByStatus(userNo, status);
            return ResponseEntity.ok().body(count);
        } catch (Exception e) {
            log.error("이슈 개수 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}")
    @Operation(summary = "이슈 수정", description = "이슈 정보를 수정합니다")
    public ResponseEntity<?> updateIssue(@PathVariable Long no, @RequestBody Issue issue) {
        log.info("## 이슈 수정 ##");
        log.info("no={}, issue={}", no, issue);

        try {
            issue.setNo(no);
            boolean result = issueService.update(issue);
            if (result) {
                return ResponseEntity.ok().body("이슈 수정 완료");
            } else {
                return ResponseEntity.badRequest().body("이슈 수정 실패");
            }
        } catch (Exception e) {
            log.error("이슈 수정 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/status")
    @Operation(summary = "이슈 상태 변경", description = "이슈의 상태를 변경합니다")
    public ResponseEntity<?> updateStatus(@PathVariable Long no, @RequestParam String status) {
        log.info("## 이슈 상태 변경 ##");
        log.info("no={}, status={}", no, status);

        try {
            boolean result = issueService.updateStatus(no, status);
            if (result) {
                return ResponseEntity.ok().body("상태 변경 완료");
            } else {
                return ResponseEntity.badRequest().body("상태 변경 실패");
            }
        } catch (Exception e) {
            log.error("이슈 상태 변경 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/mediation-proposals")
    @Operation(summary = "중재안 저장", description = "이슈에 대한 중재안을 저장합니다")
    public ResponseEntity<?> saveMediationProposals(@PathVariable Long no, @RequestBody String mediationProposals) {
        log.info("## 중재안 저장 ##");
        log.info("no={}, mediationProposals={}", no, mediationProposals);

        try {
            boolean result = issueService.saveMediationProposals(no, mediationProposals);
            if (result) {
                return ResponseEntity.ok().body("중재안 저장 완료");
            } else {
                return ResponseEntity.badRequest().body("중재안 저장 실패");
            }
        } catch (Exception e) {
            log.error("중재안 저장 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/select-proposal")
    @Operation(summary = "중재안 선택", description = "중재안 중 하나를 선택합니다")
    public ResponseEntity<?> selectMediationProposal(@PathVariable Long no, @RequestBody String selectedProposal) {
        log.info("## 중재안 선택 ##");
        log.info("no={}, selectedProposal={}", no, selectedProposal);

        try {
            boolean result = issueService.selectMediationProposal(no, selectedProposal);
            if (result) {
                return ResponseEntity.ok().body("중재안 선택 완료");
            } else {
                return ResponseEntity.badRequest().body("중재안 선택 실패");
            }
        } catch (Exception e) {
            log.error("중재안 선택 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @DeleteMapping("/{no}")
    @Operation(summary = "이슈 삭제", description = "이슈를 삭제합니다")
    public ResponseEntity<?> deleteIssue(@PathVariable Long no) {
        log.info("## 이슈 삭제 ##");
        log.info("no={}", no);

        try {
            boolean result = issueService.deleteById(no.toString());
            if (result) {
                return ResponseEntity.ok().body("이슈 삭제 완료");
            } else {
                return ResponseEntity.badRequest().body("이슈 삭제 실패");
            }
        } catch (Exception e) {
            log.error("이슈 삭제 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    /**
     * conflict_situation, requirements
     * 요약 + 핵심 쟁점 리스트(analaysis_result)를 반환하는 엔드포인트
     */
    @PostMapping("/{no}/analyze")
    @Operation(summary = "요약 분석", description = "ai를 통해 이슈의 요약과 핵심 쟁점을 분석합니다")
    public ResponseEntity<?> analyzeIssue(@PathVariable Long no) {
        log.info("## AI - 요약 분석 요청 ##");
        log.info("issueNo={}", no);

        try {
            Issue updated = issueService.analyzeIssue(no);
            return ResponseEntity.ok(updated);   // 정상 응답
        } catch (IllegalArgumentException e) {
            log.error("Invalid issueId: {}", e.getMessage());
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            log.error("Error analyzing issue: ", e);
            return ResponseEntity.status(500).body("AI 분석 중 오류 발생");
        }
    }

    @PutMapping("/{no}/opponent")
    public ResponseEntity<?> updateOpponent(@PathVariable Long no, @RequestBody Map<String, String> body) {
        log.info("## 상대방 정보 업데이트 ##");
        log.info("issueNo={}", no);

        String name = body.get("opponentName");
        String contact = body.get("opponentContact");

        log.info("## 상대방 정보 업데이트 ## no={}, name={}, contact={}", no, name, contact);

        boolean result = issueService.updateOpponent(no, name, contact);

        if (!result) {
            return ResponseEntity.badRequest().body("업데이트 실패");
        }

        return ResponseEntity.ok("상대방 정보 업데이트 완료");
    }

    @GetMapping("/user/{userNo}")
    @Operation(
        summary = "회원의 이슈 목록",
        description = "회원이 발신자 또는 상대방으로 참여한 이슈 목록을 조회합니다"
    )
    public ResponseEntity<?> getIssuesByUser(@PathVariable Long userNo) {
        log.info("## 회원의 이슈 목록 조회 (발신 + 수신) ## userNo={}", userNo);

        try {
            List<Issue> issues = issueService.selectMyIssues(userNo);
            return ResponseEntity.ok(issues);
        } catch (Exception e) {
            log.error("회원 이슈 목록 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

}
