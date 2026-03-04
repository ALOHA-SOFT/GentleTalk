package com.gentle.talk.controller.v1;

import com.gentle.talk.domain.etc.IssueCategory;
import com.gentle.talk.service.etc.IssueCategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
@Tag(name = "이슈 카테고리 API", description = "이슈 카테고리 관리 API")
public class IssueCategoryController {

    private final IssueCategoryService issueCategoryService;

    @PostMapping
    @Operation(summary = "카테고리 등록", description = "새로운 이슈 카테고리를 등록합니다")
    public ResponseEntity<?> register(@RequestBody IssueCategory category) {
        log.info("## 카테고리 등록 요청 ##");
        log.info("category={}", category);

        try {
            boolean result = issueCategoryService.register(category);
            if (result) {
                return ResponseEntity.ok().body(category);
            } else {
                return ResponseEntity.badRequest().body("카테고리 등록 실패");
            }
        } catch (Exception e) {
            log.error("카테고리 등록 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/{no}")
    @Operation(summary = "카테고리 조회", description = "카테고리 번호로 카테고리를 조회합니다")
    public ResponseEntity<?> getCategory(@PathVariable("no") Long no) {
        log.info("## 카테고리 조회 ##");
        log.info("no={}", no);

        try {
            IssueCategory category = issueCategoryService.selectById(no.toString());
            if (category != null) {
                return ResponseEntity.ok(category);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("카테고리 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/code/{code}")
    @Operation(summary = "코드로 카테고리 조회", description = "카테고리 코드로 카테고리를 조회합니다")
    public ResponseEntity<?> getCategoryByCode(@PathVariable String code) {
        log.info("## 코드로 카테고리 조회 ##");
        log.info("code={}", code);

        try {
            IssueCategory category = issueCategoryService.selectByCode(code);
            if (category != null) {
                return ResponseEntity.ok(category);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("카테고리 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping
    @Operation(summary = "모든 카테고리 조회", description = "모든 카테고리를 조회합니다")
    public ResponseEntity<?> getAllCategories() {
        log.info("## 모든 카테고리 조회 ##");

        try {
            List<IssueCategory> categories = issueCategoryService.selectAllOrdered();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            log.error("카테고리 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @GetMapping("/enabled")
    @Operation(summary = "활성화된 카테고리 조회", description = "활성화된 카테고리만 조회합니다")
    public ResponseEntity<?> getEnabledCategories() {
        log.info("## 활성화된 카테고리 조회 ##");

        try {
            List<IssueCategory> categories = issueCategoryService.selectAllEnabled();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            log.error("활성화된 카테고리 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @PutMapping("/{no}")
    @Operation(summary = "카테고리 수정", description = "카테고리 정보를 수정합니다")
    public ResponseEntity<?> updateCategory(@PathVariable("no") Long no, @RequestBody IssueCategory category) {
        log.info("## 카테고리 수정 ##");
        log.info("no={}, category={}", no, category);

        try {
            category.setNo(no);
            boolean result = issueCategoryService.update(category);
            if (result) {
                return ResponseEntity.ok().body("카테고리 수정 완료");
            } else {
                return ResponseEntity.badRequest().body("카테고리 수정 실패");
            }
        } catch (Exception e) {
            log.error("카테고리 수정 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }

    @DeleteMapping("/{no}")
    @Operation(summary = "카테고리 삭제", description = "카테고리를 삭제합니다")
    public ResponseEntity<?> deleteCategory(@PathVariable("no") Long no) {
        log.info("## 카테고리 삭제 ##");
        log.info("no={}", no);

        try {
            boolean result = issueCategoryService.deleteById(no.toString());
            if (result) {
                return ResponseEntity.ok().body("카테고리 삭제 완료");
            } else {
                return ResponseEntity.badRequest().body("카테고리 삭제 실패");
            }
        } catch (Exception e) {
            log.error("카테고리 삭제 중 오류 발생", e);
            return ResponseEntity.internalServerError().body("서버 오류: " + e.getMessage());
        }
    }
}
