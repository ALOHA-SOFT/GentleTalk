package com.gentle.talk.controller.v1;

import com.gentle.talk.domain.etc.MediationProposalLog;
import com.gentle.talk.service.etc.MediationProposalLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/mediation-logs")
@RequiredArgsConstructor
@Tag(name = "중재안 로그 API", description = "중재안 로그 관리 API (AI 캐싱)")
public class MediationProposalLogController {

    private final MediationProposalLogService mediationProposalLogService;

    @PostMapping
    @Operation(summary = "중재안 로그 등록", description = "새로운 중재안 로그를 등록합니다")
    public ResponseEntity<?> register(@RequestBody MediationProposalLog mediationLog) {
        log.info("## 중재안 로그 등록 요청 ##");

        try {
            boolean result = mediationProposalLogService.register(mediationLog);
            if (result) {
                return ResponseEntity.ok().body(mediationLog);
            } else {
                return ResponseEntity.badRequest().body("중재안 로그 등록 실패");
            }
        } catch (Exception e) {
            log.error("중재안 로그 등록 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/{no}")
    @Operation(summary = "중재안 로그 조회", description = "로그 번호로 중재안 로그를 조회합니다")
    public ResponseEntity<?> getLog(@PathVariable Long no) {
        log.info("## 중재안 로그 조회 ##");
        log.info("no={}", no);

        try {
            MediationProposalLog mediationLog = mediationProposalLogService.selectById(no.toString());
            if (mediationLog != null) {
                return ResponseEntity.ok(mediationLog);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("중재안 로그 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/similar")
    @Operation(summary = "유사한 중재안 검색", description = "유사한 중재안 로그를 검색합니다 (AI 캐싱)")
    public ResponseEntity<?> findSimilarLogs(
            @RequestParam Long categoryNo,
            @RequestParam String conflictSituationHash,
            @RequestParam(defaultValue = "5") int limit) {
        log.info("## 유사한 중재안 검색 ##");
        log.info("categoryNo={}, hash={}, limit={}", categoryNo, conflictSituationHash, limit);

        try {
            List<MediationProposalLog> logs = mediationProposalLogService.findSimilarLogs(
                    categoryNo, conflictSituationHash, limit);
            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            log.error("유사한 중재안 검색 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/popular")
    @Operation(summary = "인기 중재안", description = "재사용 횟수가 많은 인기 중재안을 조회합니다")
    public ResponseEntity<?> findPopularLogs(
            @RequestParam Long categoryNo,
            @RequestParam(defaultValue = "10") int limit) {
        log.info("## 인기 중재안 조회 ##");
        log.info("categoryNo={}, limit={}", categoryNo, limit);

        try {
            List<MediationProposalLog> logs = mediationProposalLogService.findPopularLogs(categoryNo, limit);
            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            log.error("인기 중재안 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/recent")
    @Operation(summary = "최근 중재안", description = "최근 생성된 중재안을 조회합니다")
    public ResponseEntity<?> findRecentLogs(
            @RequestParam Long categoryNo,
            @RequestParam(defaultValue = "10") int limit) {
        log.info("## 최근 중재안 조회 ##");
        log.info("categoryNo={}, limit={}", categoryNo, limit);

        try {
            List<MediationProposalLog> logs = mediationProposalLogService.findRecentLogs(categoryNo, limit);
            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            log.error("최근 중재안 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PostMapping("/hash")
    @Operation(summary = "해시값 생성", description = "갈등상황 텍스트의 해시값을 생성합니다")
    public ResponseEntity<?> generateHash(@RequestBody String content) {
        log.info("## 해시값 생성 ##");

        try {
            String hash = mediationProposalLogService.generateHash(content);
            return ResponseEntity.ok().body(hash);
        } catch (Exception e) {
            log.error("해시값 생성 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PostMapping("/get-or-create")
    @Operation(summary = "중재안 캐시 조회/생성", description = "캐시에서 중재안을 조회하거나 새로 생성합니다")
    public ResponseEntity<?> getOrCreateProposal(
            @RequestParam Long categoryNo,
            @RequestBody MediationRequest request) {
        log.info("## 중재안 캐시 조회/생성 ##");
        log.info("categoryNo={}", categoryNo);

        try {
            MediationProposalLog result = mediationProposalLogService.getOrCreateProposal(
                    categoryNo, request.getConflictSituation(), request.getRequirements());
            
            if (result != null) {
                return ResponseEntity.ok(result);
            } else {
                // 캐시 미스 - AI API 호출 필요
                return ResponseEntity.status(204).body("캐시 미스 - AI API 호출 필요");
            }
        } catch (Exception e) {
            log.error("중재안 캐시 조회/생성 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/reuse")
    @Operation(summary = "재사용 횟수 증가", description = "중재안 로그의 재사용 횟수를 증가시킵니다")
    public ResponseEntity<?> incrementReuseCount(@PathVariable Long no) {
        log.info("## 재사용 횟수 증가 ##");
        log.info("no={}", no);

        try {
            boolean result = mediationProposalLogService.incrementReuseCount(no);
            if (result) {
                return ResponseEntity.ok().body("재사용 횟수 증가 완료");
            } else {
                return ResponseEntity.badRequest().body("재사용 횟수 증가 실패");
            }
        } catch (Exception e) {
            log.error("재사용 횟수 증가 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}")
    @Operation(summary = "중재안 로그 수정", description = "중재안 로그 정보를 수정합니다")
    public ResponseEntity<?> updateLog(@PathVariable Long no, @RequestBody MediationProposalLog mediationLog) {
        log.info("## 중재안 로그 수정 ##");
        log.info("no={}, log={}", no, mediationLog);

        try {
            mediationLog.setNo(no);
            boolean result = mediationProposalLogService.update(mediationLog);
            if (result) {
                return ResponseEntity.ok().body("중재안 로그 수정 완료");
            } else {
                return ResponseEntity.badRequest().body("중재안 로그 수정 실패");
            }
        } catch (Exception e) {
            log.error("중재안 로그 수정 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @DeleteMapping("/{no}")
    @Operation(summary = "중재안 로그 삭제", description = "중재안 로그를 삭제합니다")
    public ResponseEntity<?> deleteLog(@PathVariable Long no) {
        log.info("## 중재안 로그 삭제 ##");
        log.info("no={}", no);

        try {
            boolean result = mediationProposalLogService.deleteById(no.toString());
            if (result) {
                return ResponseEntity.ok().body("중재안 로그 삭제 완료");
            } else {
                return ResponseEntity.badRequest().body("중재안 로그 삭제 실패");
            }
        } catch (Exception e) {
            log.error("중재안 로그 삭제 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    // DTO
    public static class MediationRequest {
        private String conflictSituation;
        private String requirements;

        public String getConflictSituation() {
            return conflictSituation;
        }

        public void setConflictSituation(String conflictSituation) {
            this.conflictSituation = conflictSituation;
        }

        public String getRequirements() {
            return requirements;
        }

        public void setRequirements(String requirements) {
            this.requirements = requirements;
        }
    }
}
