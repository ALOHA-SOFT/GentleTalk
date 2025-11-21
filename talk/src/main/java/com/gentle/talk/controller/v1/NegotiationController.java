package com.gentle.talk.controller.v1;

import com.gentle.talk.domain.core.Negotiation;
import com.gentle.talk.service.core.NegotiationService;
import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/negotiations")
@RequiredArgsConstructor
@Tag(name = "협상 API", description = "협상 관리 API")
public class NegotiationController {

    private final NegotiationService negotiationService;

    @PostMapping
    @Operation(summary = "협상 등록", description = "새로운 협상을 등록합니다")
    public ResponseEntity<?> register(@RequestBody Negotiation negotiation) {
        log.info("## 협상 등록 요청 ##");
        log.info("negotiation={}", negotiation);

        try {
            boolean result = negotiationService.register(negotiation);
            if (result) {
                return ResponseEntity.ok().body(negotiation);
            } else {
                return ResponseEntity.badRequest().body("협상 등록 실패");
            }
        } catch (Exception e) {
            log.error("협상 등록 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/{no}")
    @Operation(summary = "협상 조회", description = "협상 번호로 협상을 조회합니다")
    public ResponseEntity<?> getNegotiation(@PathVariable Long no) {
        log.info("## 협상 조회 ##");
        log.info("no={}", no);

        try {
            Negotiation negotiation = negotiationService.selectById(no.toString());
            if (negotiation != null) {
                return ResponseEntity.ok(negotiation);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("협상 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/issue/{issueNo}")
    @Operation(summary = "이슈의 협상 목록", description = "특정 이슈에 대한 협상 목록을 조회합니다")
    public ResponseEntity<?> getNegotiationsByIssue(@PathVariable Long issueNo) {
        log.info("## 이슈의 협상 목록 조회 ##");
        log.info("issueNo={}", issueNo);

        try {
            List<Negotiation> negotiations = negotiationService.selectByIssueNo(issueNo);
            return ResponseEntity.ok(negotiations);
        } catch (Exception e) {
            log.error("이슈 협상 목록 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userNo}")
    @Operation(summary = "협상가의 협상 목록", description = "협상가가 진행한 협상 목록을 조회합니다")
    public ResponseEntity<?> getNegotiationsByUser(@PathVariable Long userNo) {
        log.info("## 협상가의 협상 목록 조회 ##");
        log.info("userNo={}", userNo);

        try {
            List<Negotiation> negotiations = negotiationService.selectByUserNo(userNo);
            return ResponseEntity.ok(negotiations);
        } catch (Exception e) {
            log.error("협상가 협상 목록 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping
    @Operation(summary = "협상 목록 조회", description = "페이징된 협상 목록을 조회합니다")
    public ResponseEntity<?> getNegotiations(QueryParams queryParams) {
        log.info("## 협상 목록 조회 ##");
        log.info("queryParams={}", queryParams);

        try {
            PageInfo<Negotiation> pageInfo = negotiationService.page(queryParams);
            return ResponseEntity.ok(pageInfo);
        } catch (Exception e) {
            log.error("협상 목록 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/ongoing/{userNo}")
    @Operation(summary = "진행 중인 협상", description = "협상가의 진행 중인 협상을 조회합니다")
    public ResponseEntity<?> getOngoingNegotiations(@PathVariable Long userNo) {
        log.info("## 진행 중인 협상 조회 ##");
        log.info("userNo={}", userNo);

        try {
            List<Negotiation> negotiations = negotiationService.selectOngoingNegotiations(userNo);
            return ResponseEntity.ok(negotiations);
        } catch (Exception e) {
            log.error("진행 중인 협상 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/recent/{userNo}")
    @Operation(summary = "최근 협상", description = "협상가의 최근 협상을 조회합니다")
    public ResponseEntity<?> getRecentNegotiations(@PathVariable Long userNo, @RequestParam(defaultValue = "5") int limit) {
        log.info("## 최근 협상 조회 ##");
        log.info("userNo={}, limit={}", userNo, limit);

        try {
            List<Negotiation> negotiations = negotiationService.selectRecentNegotiations(userNo, limit);
            return ResponseEntity.ok(negotiations);
        } catch (Exception e) {
            log.error("최근 협상 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/count/{userNo}")
    @Operation(summary = "상태별 협상 개수", description = "협상가의 상태별 협상 개수를 조회합니다")
    public ResponseEntity<?> countByStatus(@PathVariable Long userNo, @RequestParam(required = false) String status) {
        log.info("## 상태별 협상 개수 조회 ##");
        log.info("userNo={}, status={}", userNo, status);

        try {
            int count = negotiationService.countByStatus(userNo, status);
            return ResponseEntity.ok().body(count);
        } catch (Exception e) {
            log.error("협상 개수 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}")
    @Operation(summary = "협상 수정", description = "협상 정보를 수정합니다")
    public ResponseEntity<?> updateNegotiation(@PathVariable Long no, @RequestBody Negotiation negotiation) {
        log.info("## 협상 수정 ##");
        log.info("no={}, negotiation={}", no, negotiation);

        try {
            negotiation.setNo(no);
            boolean result = negotiationService.update(negotiation);
            if (result) {
                return ResponseEntity.ok().body("협상 수정 완료");
            } else {
                return ResponseEntity.badRequest().body("협상 수정 실패");
            }
        } catch (Exception e) {
            log.error("협상 수정 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/accept")
    @Operation(summary = "협상 수락", description = "협상을 수락합니다")
    public ResponseEntity<?> acceptNegotiation(@PathVariable Long no) {
        log.info("## 협상 수락 ##");
        log.info("no={}", no);

        try {
            boolean result = negotiationService.acceptNegotiation(no);
            if (result) {
                return ResponseEntity.ok().body("협상 수락 완료");
            } else {
                return ResponseEntity.badRequest().body("협상 수락 실패");
            }
        } catch (Exception e) {
            log.error("협상 수락 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/finalize")
    @Operation(summary = "협상 체결", description = "협상을 체결합니다")
    public ResponseEntity<?> finalizeNegotiation(@PathVariable Long no) {
        log.info("## 협상 체결 ##");
        log.info("no={}", no);

        try {
            boolean result = negotiationService.finalizeNegotiation(no);
            if (result) {
                return ResponseEntity.ok().body("협상 체결 완료");
            } else {
                return ResponseEntity.badRequest().body("협상 체결 실패");
            }
        } catch (Exception e) {
            log.error("협상 체결 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/reject")
    @Operation(summary = "협상 불발", description = "협상을 불발 처리합니다")
    public ResponseEntity<?> rejectNegotiation(@PathVariable Long no) {
        log.info("## 협상 불발 ##");
        log.info("no={}", no);

        try {
            boolean result = negotiationService.rejectNegotiation(no);
            if (result) {
                return ResponseEntity.ok().body("협상 불발 처리 완료");
            } else {
                return ResponseEntity.badRequest().body("협상 불발 처리 실패");
            }
        } catch (Exception e) {
            log.error("협상 불발 처리 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/status")
    @Operation(summary = "협상 상태 변경", description = "협상의 상태를 변경합니다")
    public ResponseEntity<?> updateStatus(@PathVariable Long no, @RequestParam String status) {
        log.info("## 협상 상태 변경 ##");
        log.info("no={}, status={}", no, status);

        try {
            boolean result = negotiationService.updateStatus(no, status);
            if (result) {
                return ResponseEntity.ok().body("상태 변경 완료");
            } else {
                return ResponseEntity.badRequest().body("상태 변경 실패");
            }
        } catch (Exception e) {
            log.error("협상 상태 변경 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @DeleteMapping("/{no}")
    @Operation(summary = "협상 삭제", description = "협상을 삭제합니다")
    public ResponseEntity<?> deleteNegotiation(@PathVariable Long no) {
        log.info("## 협상 삭제 ##");
        log.info("no={}", no);

        try {
            boolean result = negotiationService.deleteById(no.toString());
            if (result) {
                return ResponseEntity.ok().body("협상 삭제 완료");
            } else {
                return ResponseEntity.badRequest().body("협상 삭제 실패");
            }
        } catch (Exception e) {
            log.error("협상 삭제 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }
}
