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
@RequestMapping("/api/v1/users")
@Tag(name = "User Controller", description = "사용자 관리 API")
public class UserController {

    @Autowired
    private UserService userService;

    @Operation(summary = "사용자 목록 조회", description = "페이징을 포함한 사용자 목록을 조회합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "조회 성공"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @GetMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<PageInfo<Users>> getUserList(
            @Parameter(description = "페이지 번호", example = "1") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "페이지 크기", example = "10") @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "검색 키워드") @RequestParam(required = false) String keyword) {
        
        try {
            QueryParams queryParams = new QueryParams();
            queryParams.setPage(page);
            queryParams.setSize(size);
            queryParams.setSearch(keyword);
            
            PageInfo<Users> userList = userService.page(queryParams);
            log.info("사용자 목록 조회 성공 - 총 {}건", userList.getTotal());
            
            return ResponseEntity.ok(userList);
        } catch (Exception e) {
            log.error("사용자 목록 조회 실패", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(summary = "사용자 상세 조회", description = "사용자 번호로 상세 정보를 조회합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "조회 성공"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @GetMapping("/{no}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Users> getUserDetail(
            @Parameter(description = "사용자 번호", example = "1") @PathVariable Long no) {
        
        try {
            Users user = userService.select(no);
            if (user == null) {
                log.warn("사용자를 찾을 수 없음 - no: {}", no);
                return ResponseEntity.notFound().build();
            }
            
            log.info("사용자 상세 조회 성공 - no: {}, username: {}", no, user.getUsername());
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            log.error("사용자 상세 조회 실패 - no: {}", no, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(summary = "사용자 정보 수정", description = "사용자 정보를 수정합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "수정 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PutMapping("/{no}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<String> updateUser(
            @Parameter(description = "사용자 번호", example = "1") @PathVariable Long no,
            @RequestBody Users user) {
        
        try {
            // 사용자 존재 여부 확인
            Users existingUser = userService.select(no);
            if (existingUser == null) {
                log.warn("수정할 사용자를 찾을 수 없음 - no: {}", no);
                return ResponseEntity.notFound().build();
            }
            
            user.setNo(no);
            boolean result = userService.updateById(user);
            
            if (result) {
                log.info("사용자 정보 수정 성공 - no: {}", no);
                return ResponseEntity.ok("사용자 정보가 성공적으로 수정되었습니다.");
            } else {
                log.warn("사용자 정보 수정 실패 - no: {}", no);
                return ResponseEntity.badRequest().body("사용자 정보 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            log.error("사용자 정보 수정 중 오류 발생 - no: {}", no, e);
            return ResponseEntity.internalServerError().body("서버 오류가 발생했습니다.");
        }
    }

    @Operation(summary = "비밀번호 변경", description = "사용자의 비밀번호를 변경합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "변경 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PutMapping("/{no}/password")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<String> changePassword(
            @Parameter(description = "사용자 번호", example = "1") @PathVariable Long no,
            @RequestBody Users passwordData) {
        
        try {
            Users existingUser = userService.select(no);
            if (existingUser == null) {
                log.warn("사용자를 찾을 수 없음 - no: {}", no);
                return ResponseEntity.notFound().build();
            }
            
            // 현재 비밀번호 확인
            if (!userService.checkPassword(existingUser, passwordData.getPassword())) {
                log.warn("현재 비밀번호가 일치하지 않음 - no: {}", no);
                return ResponseEntity.badRequest().body("현재 비밀번호가 일치하지 않습니다.");
            }
            
            // 새 비밀번호와 확인 비밀번호 일치 여부 확인
            if (!passwordData.getNewPassword().equals(passwordData.getConfirmPassword())) {
                log.warn("새 비밀번호와 확인 비밀번호가 일치하지 않음 - no: {}", no);
                return ResponseEntity.badRequest().body("새 비밀번호와 확인 비밀번호가 일치하지 않습니다.");
            }
            
            existingUser.setPassword(passwordData.getNewPassword());
            boolean result = userService.updateById(existingUser);
            
            if (result) {
                log.info("비밀번호 변경 성공 - no: {}", no);
                return ResponseEntity.ok("비밀번호가 성공적으로 변경되었습니다.");
            } else {
                log.warn("비밀번호 변경 실패 - no: {}", no);
                return ResponseEntity.badRequest().body("비밀번호 변경에 실패했습니다.");
            }
        } catch (Exception e) {
            log.error("비밀번호 변경 중 오류 발생 - no: {}", no, e);
            return ResponseEntity.internalServerError().body("서버 오류가 발생했습니다.");
        }
    }

    @Operation(summary = "아이디 찾기", description = "이름과 이메일로 아이디를 찾습니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "조회 성공"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PostMapping("/find-username")
    public ResponseEntity<String> findUsername(
            @Parameter(description = "이름") @RequestParam String name,
            @Parameter(description = "이메일") @RequestParam String email) {
        
        try {
            Users user = userService.findByNameAndEmail(name, email);
            if (user == null) {
                log.warn("사용자를 찾을 수 없음 - name: {}, email: {}", name, email);
                return ResponseEntity.notFound().build();
            }
            
            log.info("아이디 찾기 성공 - name: {}, email: {}", name, email);
            return ResponseEntity.ok(user.getUsername());
        } catch (Exception e) {
            log.error("아이디 찾기 중 오류 발생 - name: {}, email: {}", name, email, e);
            return ResponseEntity.internalServerError().body("서버 오류가 발생했습니다.");
        }
    }

    @Operation(summary = "비밀번호 재설정", description = "아이디와 이메일로 임시 비밀번호를 생성합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "재설정 성공"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음"),
        @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(
            @Parameter(description = "사용자명") @RequestParam String username,
            @Parameter(description = "이메일") @RequestParam String email) {
        
        try {
            boolean result = userService.resetPassword(username, email);
            if (result) {
                log.info("비밀번호 재설정 성공 - username: {}, email: {}", username, email);
                return ResponseEntity.ok("임시 비밀번호가 이메일로 전송되었습니다.");
            } else {
                log.warn("사용자를 찾을 수 없음 - username: {}, email: {}", username, email);
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("비밀번호 재설정 중 오류 발생 - username: {}, email: {}", username, email, e);
            return ResponseEntity.internalServerError().body("서버 오류가 발생했습니다.");
        }
    }

    
}