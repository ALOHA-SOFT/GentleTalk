package com.gentle.talk.controller.v1;

import com.gentle.talk.domain.users.NegotiatorProfile;
import com.gentle.talk.service.users.NegotiatorProfileService;
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
@RequestMapping("/api/v1/negotiator-profiles")
@RequiredArgsConstructor
@Tag(name = "협상가 프로필 API", description = "협상가 프로필 관리 API")
public class NegotiatorProfileController {

    private final NegotiatorProfileService negotiatorProfileService;

    @PostMapping
    @Operation(summary = "협상가 프로필 등록", description = "새로운 협상가 프로필을 등록합니다")
    public ResponseEntity<?> register(@RequestBody NegotiatorProfile profile) {
        log.info("## 협상가 프로필 등록 요청 ##");
        log.info("profile={}", profile);

        try {
            boolean result = negotiatorProfileService.register(profile);
            if (result) {
                return ResponseEntity.ok().body(profile);
            } else {
                return ResponseEntity.badRequest().body("협상가 프로필 등록 실패");
            }
        } catch (Exception e) {
            log.error("협상가 프로필 등록 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/{no}")
    @Operation(summary = "협상가 프로필 조회", description = "프로필 번호로 협상가 프로필을 조회합니다")
    public ResponseEntity<?> getProfile(@PathVariable Long no) {
        log.info("## 협상가 프로필 조회 ##");
        log.info("no={}", no);

        try {
            NegotiatorProfile profile = negotiatorProfileService.selectById(no.toString());
            if (profile != null) {
                return ResponseEntity.ok(profile);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("협상가 프로필 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userNo}")
    @Operation(summary = "회원 번호로 협상가 프로필 조회", description = "회원 번호로 협상가 프로필을 조회합니다")
    public ResponseEntity<?> getProfileByUserNo(@PathVariable Long userNo) {
        log.info("## 회원 번호로 협상가 프로필 조회 ##");
        log.info("userNo={}", userNo);

        try {
            NegotiatorProfile profile = negotiatorProfileService.selectByUserNo(userNo);
            if (profile != null) {
                return ResponseEntity.ok(profile);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("협상가 프로필 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping
    @Operation(summary = "협상가 프로필 목록 조회", description = "페이징된 협상가 프로필 목록을 조회합니다")
    public ResponseEntity<?> getProfiles(QueryParams queryParams) {
        log.info("## 협상가 프로필 목록 조회 ##");
        log.info("queryParams={}", queryParams);

        try {
            PageInfo<NegotiatorProfile> pageInfo = negotiatorProfileService.page(queryParams);
            return ResponseEntity.ok(pageInfo);
        } catch (Exception e) {
            log.error("협상가 프로필 목록 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/specialty/{categoryCode}")
    @Operation(summary = "전문 분야로 협상가 검색", description = "특정 전문 분야의 협상가 목록을 조회합니다")
    public ResponseEntity<?> getProfilesBySpecialty(@PathVariable String categoryCode) {
        log.info("## 전문 분야로 협상가 검색 ##");
        log.info("categoryCode={}", categoryCode);

        try {
            List<NegotiatorProfile> profiles = negotiatorProfileService.findBySpecialty(categoryCode);
            return ResponseEntity.ok(profiles);
        } catch (Exception e) {
            log.error("협상가 검색 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/top-rated")
    @Operation(summary = "평점 상위 협상가", description = "평점 순으로 상위 협상가를 조회합니다")
    public ResponseEntity<?> getTopRatedNegotiators(@RequestParam(defaultValue = "10") int limit) {
        log.info("## 평점 상위 협상가 조회 ##");
        log.info("limit={}", limit);

        try {
            List<NegotiatorProfile> profiles = negotiatorProfileService.findTopRatedNegotiators(limit);
            return ResponseEntity.ok(profiles);
        } catch (Exception e) {
            log.error("평점 상위 협상가 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/top-success-rate")
    @Operation(summary = "성공률 상위 협상가", description = "성공률 순으로 상위 협상가를 조회합니다")
    public ResponseEntity<?> getTopSuccessRateNegotiators(@RequestParam(defaultValue = "10") int limit) {
        log.info("## 성공률 상위 협상가 조회 ##");
        log.info("limit={}", limit);

        try {
            List<NegotiatorProfile> profiles = negotiatorProfileService.findTopSuccessRateNegotiators(limit);
            return ResponseEntity.ok(profiles);
        } catch (Exception e) {
            log.error("성공률 상위 협상가 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}")
    @Operation(summary = "협상가 프로필 수정", description = "협상가 프로필 정보를 수정합니다")
    public ResponseEntity<?> updateProfile(@PathVariable Long no, @RequestBody NegotiatorProfile profile) {
        log.info("## 협상가 프로필 수정 ##");
        log.info("no={}, profile={}", no, profile);

        try {
            profile.setNo(no);
            boolean result = negotiatorProfileService.update(profile);
            if (result) {
                return ResponseEntity.ok().body("협상가 프로필 수정 완료");
            } else {
                return ResponseEntity.badRequest().body("협상가 프로필 수정 실패");
            }
        } catch (Exception e) {
            log.error("협상가 프로필 수정 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}/rating")
    @Operation(summary = "협상가 평점 업데이트", description = "협상가의 평점을 업데이트합니다")
    public ResponseEntity<?> updateRating(@PathVariable Long no, @RequestParam double rating) {
        log.info("## 협상가 평점 업데이트 ##");
        log.info("no={}, rating={}", no, rating);

        try {
            boolean result = negotiatorProfileService.updateRating(no, rating);
            if (result) {
                return ResponseEntity.ok().body("평점 업데이트 완료");
            } else {
                return ResponseEntity.badRequest().body("평점 업데이트 실패");
            }
        } catch (Exception e) {
            log.error("평점 업데이트 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @DeleteMapping("/{no}")
    @Operation(summary = "협상가 프로필 삭제", description = "협상가 프로필을 삭제합니다")
    public ResponseEntity<?> deleteProfile(@PathVariable Long no) {
        log.info("## 협상가 프로필 삭제 ##");
        log.info("no={}", no);

        try {
            boolean result = negotiatorProfileService.deleteById(no.toString());
            if (result) {
                return ResponseEntity.ok().body("협상가 프로필 삭제 완료");
            } else {
                return ResponseEntity.badRequest().body("협상가 프로필 삭제 실패");
            }
        } catch (Exception e) {
            log.error("협상가 프로필 삭제 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }
}
