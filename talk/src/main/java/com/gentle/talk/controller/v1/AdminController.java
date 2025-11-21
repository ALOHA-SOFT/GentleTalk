package com.gentle.talk.controller.v1;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import com.gentle.talk.domain.users.Users;
import com.gentle.talk.service.users.UserService;
import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.common.QueryParams;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/admin/v1")
@Tag(name = "Admin Controller", description = "관리자 API")
public class AdminController {

    @Autowired
    private UserService userService;

    @Operation(summary = "전체 사용자 목록 조회", description = "관리자용 전체 사용자 목록을 조회합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "조회 성공"),
        @ApiResponse(responseCode = "403", description = "권한 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @GetMapping("/users")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PageInfo<Users>> getAllUsers(
            @Parameter(description = "페이지 번호", example = "1") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "페이지 크기", example = "10") @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "검색 키워드") @RequestParam(required = false) String search) {
        
        try {
            QueryParams queryParams = new QueryParams();
            queryParams.setPage(page);
            queryParams.setSize(size);
            queryParams.setSearch(search);
            
            PageInfo<Users> userList = userService.page(queryParams);
            log.info("관리자 - 전체 사용자 목록 조회 성공 - 총 {}건", userList.getTotal());
            
            return ResponseEntity.ok(userList);
        } catch (Exception e) {
            log.error("관리자 - 전체 사용자 목록 조회 실패", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(summary = "사용자 상세 조회", description = "관리자용 사용자 상세 정보를 조회합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "조회 성공"),
        @ApiResponse(responseCode = "403", description = "권한 없음"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @GetMapping("/users/{no}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Users> getUserDetail(
            @Parameter(description = "사용자 번호", example = "1") @PathVariable Long no) {
        
        try {
            Users user = userService.select(no);
            if (user == null) {
                log.warn("관리자 - 사용자를 찾을 수 없음 - no: {}", no);
                return ResponseEntity.notFound().build();
            }
            
            log.info("관리자 - 사용자 상세 조회 성공 - no: {}, username: {}", no, user.getUsername());
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            log.error("관리자 - 사용자 상세 조회 실패 - no: {}", no, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(summary = "사용자 등록", description = "관리자가 새로운 사용자를 등록합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "등록 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청"),
        @ApiResponse(responseCode = "403", description = "권한 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PostMapping("/users")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> createUser(@RequestBody Users user) {
        
        try {
            // 사용자명 중복 체크
            Users existingUser = userService.selectByUsername(user.getUsername());
            if (existingUser != null) {
                log.warn("관리자 - 사용자명 중복 - username: {}", user.getUsername());
                return ResponseEntity.badRequest().body("이미 존재하는 사용자명입니다.");
            }
            
            boolean result = userService.join(user);
            if (result) {
                log.info("관리자 - 사용자 등록 성공 - username: {}", user.getUsername());
                return ResponseEntity.status(201).body("사용자가 성공적으로 등록되었습니다.");
            } else {
                log.warn("관리자 - 사용자 등록 실패 - username: {}", user.getUsername());
                return ResponseEntity.badRequest().body("사용자 등록에 실패했습니다.");
            }
        } catch (Exception e) {
            log.error("관리자 - 사용자 등록 중 오류 발생 - username: {}", user.getUsername(), e);
            return ResponseEntity.internalServerError().body("서버 오류가 발생했습니다.");
        }
    }

    @Operation(summary = "사용자 정보 수정", description = "관리자가 사용자 정보를 수정합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "수정 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청"),
        @ApiResponse(responseCode = "403", description = "권한 없음"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PutMapping("/users/{no}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> updateUser(
            @Parameter(description = "사용자 번호", example = "1") @PathVariable Long no,
            @RequestBody Users user) {
        
        try {
            // 사용자 존재 여부 확인
            Users existingUser = userService.select(no);
            if (existingUser == null) {
                log.warn("관리자 - 수정할 사용자를 찾을 수 없음 - no: {}", no);
                return ResponseEntity.notFound().build();
            }
            
            user.setNo(no);
            boolean result = userService.updateById(user);
            
            if (result) {
                log.info("관리자 - 사용자 정보 수정 성공 - no: {}", no);
                return ResponseEntity.ok("사용자 정보가 성공적으로 수정되었습니다.");
            } else {
                log.warn("관리자 - 사용자 정보 수정 실패 - no: {}", no);
                return ResponseEntity.badRequest().body("사용자 정보 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            log.error("관리자 - 사용자 정보 수정 중 오류 발생 - no: {}", no, e);
            return ResponseEntity.internalServerError().body("서버 오류가 발생했습니다.");
        }
    }

    @Operation(summary = "사용자 계정 활성화/비활성화", description = "관리자가 사용자 계정을 활성화하거나 비활성화합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "상태 변경 성공"),
        @ApiResponse(responseCode = "403", description = "권한 없음"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PutMapping("/users/{no}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> updateUserStatus(
            @Parameter(description = "사용자 번호", example = "1") @PathVariable Long no,
            @Parameter(description = "활성화 상태", example = "true") @RequestParam Boolean enabled) {
        
        try {
            Users existingUser = userService.select(no);
            if (existingUser == null) {
                log.warn("관리자 - 사용자를 찾을 수 없음 - no: {}", no);
                return ResponseEntity.notFound().build();
            }
            
            existingUser.setEnabled(enabled);
            boolean result = userService.updateById(existingUser);
            
            if (result) {
                String status = enabled ? "활성화" : "비활성화";
                log.info("관리자 - 사용자 계정 {} 성공 - no: {}", status, no);
                return ResponseEntity.ok("사용자 계정이 성공적으로 " + status + "되었습니다.");
            } else {
                log.warn("관리자 - 사용자 계정 상태 변경 실패 - no: {}", no);
                return ResponseEntity.badRequest().body("사용자 계정 상태 변경에 실패했습니다.");
            }
        } catch (Exception e) {
            log.error("관리자 - 사용자 계정 상태 변경 중 오류 발생 - no: {}", no, e);
            return ResponseEntity.internalServerError().body("서버 오류가 발생했습니다.");
        }
    }

    @Operation(summary = "사용자 삭제", description = "관리자가 사용자를 삭제합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "삭제 성공"),
        @ApiResponse(responseCode = "403", description = "권한 없음"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @DeleteMapping("/users/{no}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> deleteUser(
            @Parameter(description = "사용자 번호", example = "1") @PathVariable Long no) {
        
        try {
            Users existingUser = userService.select(no);
            if (existingUser == null) {
                log.warn("관리자 - 삭제할 사용자를 찾을 수 없음 - no: {}", no);
                return ResponseEntity.notFound().build();
            }
            
            boolean result = userService.delete(no);
            if (result) {
                log.info("관리자 - 사용자 삭제 성공 - no: {}, username: {}", no, existingUser.getUsername());
                return ResponseEntity.ok("사용자가 성공적으로 삭제되었습니다.");
            } else {
                log.warn("관리자 - 사용자 삭제 실패 - no: {}", no);
                return ResponseEntity.badRequest().body("사용자 삭제에 실패했습니다.");
            }
        } catch (Exception e) {
            log.error("관리자 - 사용자 삭제 중 오류 발생 - no: {}", no, e);
            return ResponseEntity.internalServerError().body("서버 오류가 발생했습니다.");
        }
    }

    @Operation(summary = "사용자 비밀번호 재설정", description = "관리자가 사용자의 비밀번호를 강제로 재설정합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "재설정 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청"),
        @ApiResponse(responseCode = "403", description = "권한 없음"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PutMapping("/users/{no}/reset-password")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> adminResetPassword(
            @Parameter(description = "사용자 번호", example = "1") @PathVariable Long no,
            @RequestBody Users passwordData) {
        
        try {
            Users existingUser = userService.select(no);
            if (existingUser == null) {
                log.warn("관리자 - 비밀번호 재설정할 사용자를 찾을 수 없음 - no: {}", no);
                return ResponseEntity.notFound().build();
            }
            
            if (passwordData.getNewPassword() == null || passwordData.getNewPassword().trim().isEmpty()) {
                log.warn("관리자 - 새 비밀번호가 비어있음 - no: {}", no);
                return ResponseEntity.badRequest().body("새 비밀번호를 입력해주세요.");
            }
            
            existingUser.setPassword(passwordData.getNewPassword());
            boolean result = userService.updateById(existingUser);
            
            if (result) {
                log.info("관리자 - 사용자 비밀번호 강제 재설정 성공 - no: {}", no);
                return ResponseEntity.ok("사용자의 비밀번호가 성공적으로 재설정되었습니다.");
            } else {
                log.warn("관리자 - 사용자 비밀번호 재설정 실패 - no: {}", no);
                return ResponseEntity.badRequest().body("비밀번호 재설정에 실패했습니다.");
            }
        } catch (Exception e) {
            log.error("관리자 - 사용자 비밀번호 재설정 중 오류 발생 - no: {}", no, e);
            return ResponseEntity.internalServerError().body("서버 오류가 발생했습니다.");
        }
    }

    @Operation(summary = "시스템 통계", description = "관리자용 시스템 통계 정보를 제공합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "조회 성공"),
        @ApiResponse(responseCode = "403", description = "권한 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @GetMapping("/statistics")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Object> getSystemStatistics() {
        
        try {
            // 전체 사용자 수 조회
            PageInfo<Users> allUsers = userService.page(1, Integer.MAX_VALUE);
            
            // 활성 사용자 수 계산
            long activeUserCount = allUsers.getList().stream()
                    .filter(user -> user.getEnabled() != null && user.getEnabled())
                    .count();
            
            // 비활성 사용자 수 계산
            long inactiveUserCount = allUsers.getTotal() - activeUserCount;
            
            // 통계 정보 생성
            var statistics = new Object() {
                public final long totalUsers = allUsers.getTotal();
                public final long activeUsers = activeUserCount;
                public final long inactiveUsers = inactiveUserCount;
                public final String lastUpdated = java.time.LocalDateTime.now().toString();
            };
            
            log.info("관리자 - 시스템 통계 조회 성공 - 총 사용자: {}, 활성: {}, 비활성: {}", 
                    statistics.totalUsers, statistics.activeUsers, statistics.inactiveUsers);
            
            return ResponseEntity.ok(statistics);
        } catch (Exception e) {
            log.error("관리자 - 시스템 통계 조회 실패", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}