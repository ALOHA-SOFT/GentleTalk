package com.gentle.talk.controller.v1;

import java.util.List;

import org.springframework.security.core.Authentication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.core.FormalNotice;
import com.gentle.talk.domain.users.Users;
import com.gentle.talk.service.core.FormalNoticeService;
import com.gentle.talk.service.users.UserService;
import com.github.pagehelper.PageInfo;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/v1/formal-notice")
@RequiredArgsConstructor
@Tag(name = "내용 증명 API", description = "내용 증명 관리 API")
public class FormalNoticeController {

    private final FormalNoticeService formalNoticeService;
    private final UserService userService;

    @PostMapping("/generate")
    @Operation(summary = "내용증명 등록", description = "새로운 내용증명을 등록합니다")
    public ResponseEntity<?> register(@RequestBody FormalNotice formalNotice, Authentication authentication) {
        log.info("## 내용증명 등록 요청 ##");
        log.info("formalNotice={}", formalNotice);
        log.info("authentication={}", authentication);

        try {
            if (authentication == null) {
                return ResponseEntity.status(401).body("인증 정보가 없습니다. 다시 로그인해주세요.");
            }

            String username = authentication.getName();
            Users user = userService.selectByUsername(username);

            if (user == null) {
                return ResponseEntity.status(401).body("회원 정보를 찾을 수 없습니다.");
            }

            formalNotice.setUserNo(user.getNo());

            boolean result = formalNoticeService.register(formalNotice);

            if (result) {
                return ResponseEntity.ok().body(formalNotice);
            } else {
                return ResponseEntity.badRequest().body("내용증명 등록 실패");
            }
        } catch (Exception e) {
            log.error("내용증명 등록 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/{no}")
    @Operation(summary = "내용증명 조회", description = "내용증명 번호로 내용을 조회합니다")
    public ResponseEntity<?> getFormalNotice(@PathVariable("no") Long no) {
        log.info("## 내용증명 조회 ##");
        log.info("no={}", no);

        try {
            FormalNotice formalNotice = formalNoticeService.selectByFormalNoticeNo(no);
            if (formalNotice != null) {
                return ResponseEntity.ok(formalNotice);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("내용증명 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/code/{categoryKey}")
    @Operation(summary = "내용증명 코드 조회", description = "카테고리 키(코드)로 내용을 조회합니다")
    public ResponseEntity<?> getFormalNoticeByCode(@PathVariable("categoryKey") String categoryKey) {
        log.info("## 내용증명 코드 조회 ##");
        log.info("categoryKey={}", categoryKey);

        try {
            FormalNotice formalNotice = formalNoticeService.selectByFormalNoticeCode(categoryKey);
            if (formalNotice != null) {
                return ResponseEntity.ok(formalNotice);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("내용증명 코드 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userNo}")
    @Operation(summary = "사용자의 내용증명 목록", description = "특정 사용자의 내용증명 목록을 조회합니다")
    public ResponseEntity<?> getFormalNoticesByUser(@PathVariable("userNo") Long userNo) {
        log.info("## 사용자의 내용증명 목록 조회 ##");
        log.info("userNo={}", userNo);

        try {
            List<FormalNotice> formalNotices = formalNoticeService.selectByUserNo(userNo);
            return ResponseEntity.ok(formalNotices);
        } catch (Exception e) {
            log.error("사용자 내용증명 목록 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping
    @Operation(summary = "내용증명 목록 조회", description = "페이징된 내용증명 목록을 조회합니다")
    public ResponseEntity<?> getFormalNotices(QueryParams queryParams) {
        log.info("## 내용증명 목록 조회 ##");
        log.info("queryParams={}", queryParams);

        try {
            PageInfo<FormalNotice> pageInfo = formalNoticeService.page(queryParams);
            return ResponseEntity.ok(pageInfo);
        } catch (Exception e) {
            log.error("내용증명 목록 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/count/{userNo}")
    @Operation(summary = "상태별 내용증명 개수", description = "사용자의 상태별 내용증명 개수를 조회합니다")
    public ResponseEntity<?> countByStatus(
            @PathVariable("userNo") Long userNo,
            @RequestParam(required = false) String status) {
        log.info("## 상태별 내용증명 개수 조회 ##");
        log.info("userNo={}, status={}", userNo, status);

        try {
            int count = formalNoticeService.countByStatus(userNo, status);
            return ResponseEntity.ok().body(count);
        } catch (Exception e) {
            log.error("내용증명 개수 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}")
    @Operation(summary = "내용증명 수정", description = "내용증명 정보를 수정합니다")
    public ResponseEntity<?> updateFormalNotice(
            @PathVariable("no") Long no,
            @RequestBody FormalNotice formalNotice) {
        log.info("## 내용증명 수정 ##");
        log.info("no={}, formalNotice={}", no, formalNotice);

        try {
            formalNotice.setNo(no);
            boolean result = formalNoticeService.update(formalNotice);
            if (result) {
                return ResponseEntity.ok().body("내용증명 수정 완료");
            } else {
                return ResponseEntity.badRequest().body("내용증명 수정 실패");
            }
        } catch (Exception e) {
            log.error("내용증명 수정 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/status")
    @Operation(summary = "내용증명 상태 변경", description = "내용증명의 상태를 변경합니다")
    public ResponseEntity<?> updateStatus(
            @PathVariable("no") Long no,
            @RequestParam("status") String status) {
        log.info("## 내용증명 상태 변경 ##");
        log.info("no={}, status={}", no, status);

        try {
            boolean result = formalNoticeService.updateStatus(no, status);
            if (result) {
                return ResponseEntity.ok().body("상태 변경 완료");
            } else {
                return ResponseEntity.badRequest().body("상태 변경 실패");
            }
        } catch (Exception e) {
            log.error("내용증명 상태 변경 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @DeleteMapping("/{no}")
    @Operation(summary = "내용증명 삭제", description = "내용증명을 삭제합니다")
    public ResponseEntity<?> deleteFormalNotice(@PathVariable("no") Long no) {
        log.info("## 내용증명 삭제 ##");
        log.info("no={}", no);

        try {
            // no로 id 추출
            String id = formalNoticeService.selectByFormalNoticeNo(no).getId();
            boolean result = formalNoticeService.deleteById(id);
            if (result) {
                return ResponseEntity.ok().body("내용증명 삭제 완료");
            } else {
                return ResponseEntity.badRequest().body("내용증명 삭제 실패");
            }
        } catch (Exception e) {
            log.error("내용증명 삭제 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }
}