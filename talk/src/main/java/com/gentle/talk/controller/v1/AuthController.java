package com.gentle.talk.controller.v1;

import com.gentle.talk.domain.users.Users;
import com.gentle.talk.security.jwt.JwtTokenProvider;
import com.gentle.talk.service.users.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "인증 API", description = "JWT 인증 관련 API")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserService userService;

    @PostMapping("/login")
    @Operation(summary = "로그인", description = "사용자명과 비밀번호로 로그인하여 JWT 토큰 발급")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        log.info("## JWT 로그인 요청 ##");
        log.info("username={}", loginRequest.getUsername());

        try {
            // 1. 인증 처리
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()
                    )
            );

            // 2. UserDetails 조회
            UserDetails userDetails = userDetailsService.loadUserByUsername(loginRequest.getUsername());

            // 3. JWT 토큰 생성
            String accessToken = jwtTokenProvider.generateAccessToken(userDetails);
            String refreshToken = jwtTokenProvider.generateRefreshToken(userDetails);

            // 4. 사용자 정보 조회
            Users user = userService.selectByUsername(loginRequest.getUsername());

            // 5. 응답 생성
            Map<String, Object> response = new HashMap<>();
            response.put("accessToken", accessToken);
            response.put("refreshToken", refreshToken);
            response.put("tokenType", "Bearer");
            response.put("user", Map.of(
                    "no", user.getNo(),
                    "username", user.getUsername(),
                    "name", user.getName(),
                    "email", user.getEmail()
            ));

            log.info("JWT 로그인 성공: {}", loginRequest.getUsername());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("JWT 로그인 실패", e);
            return ResponseEntity.status(401).body(Map.of(
                    "error", "인증 실패",
                    "message", "사용자명 또는 비밀번호가 올바르지 않습니다."
            ));
        }
    }

    @PostMapping("/refresh")
    @Operation(summary = "토큰 갱신", description = "Refresh Token으로 새로운 Access Token 발급")
    public ResponseEntity<?> refresh(@RequestBody RefreshRequest refreshRequest) {
        log.info("## JWT 토큰 갱신 요청 ##");

        try {
            String refreshToken = refreshRequest.getRefreshToken();

            // 1. Refresh Token 유효성 검증
            if (!jwtTokenProvider.validateToken(refreshToken)) {
                return ResponseEntity.status(401).body(Map.of(
                        "error", "유효하지 않은 토큰",
                        "message", "Refresh Token이 만료되었거나 유효하지 않습니다."
                ));
            }

            // 2. 사용자명 추출
            String username = jwtTokenProvider.getUsernameFromToken(refreshToken);

            // 3. UserDetails 조회
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);

            // 4. 새로운 Access Token 생성
            String newAccessToken = jwtTokenProvider.generateAccessToken(userDetails);

            // 5. 응답 생성
            Map<String, Object> response = new HashMap<>();
            response.put("accessToken", newAccessToken);
            response.put("tokenType", "Bearer");

            log.info("JWT 토큰 갱신 성공: {}", username);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("JWT 토큰 갱신 실패", e);
            return ResponseEntity.status(401).body(Map.of(
                    "error", "토큰 갱신 실패",
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * 현재 로그인 사용자 정보 조회
     */
    @GetMapping("/me")
    @Operation(summary = "현재 사용자 정보", description = "JWT 토큰으로 현재 로그인한 사용자 정보 조회")
    public ResponseEntity<?> getCurrentUser(Authentication authentication) {
        log.info("## 현재 사용자 정보 조회 ##");

        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of(
                        "error", "인증되지 않음",
                        "message", "로그인이 필요합니다."
                ));
            }

            String username = authentication.getName();
            Users user = userService.selectByUsername(username);

            if (user == null) {
                return ResponseEntity.status(404).body(Map.of(
                        "error", "사용자 없음",
                        "message", "사용자 정보를 찾을 수 없습니다."
                ));
            }

            Map<String, Object> userMap = new HashMap<>();
            userMap.put("no", user.getNo());
            userMap.put("username", user.getUsername());
            userMap.put("name", user.getName());
            userMap.put("email", user.getEmail());
            userMap.put("tel", user.getTel());
            userMap.put("birth", user.getBirth());
            userMap.put("gender", user.getGender());
            userMap.put("type", user.getType());   
            userMap.put("address", user.getAddress()); 
            userMap.put("enabled", user.getEnabled());

            Map<String, Object> response = new HashMap<>();
            response.put("user", userMap);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("현재 사용자 정보 조회 실패", e);
            return ResponseEntity.status(500).body(Map.of(
                    "error", "조회 실패",
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * 현재 로그인 사용자 정보 수정
     * Flutter 에서 보내는 body:
     *  {
     *    "username": "...",
     *    "name": "...",
     *    "email": "...",
     *    "tel": "...",
     *    "birth": "...",
     *    "gender": "male/female",
     *    "type": "USER",
     *    "newPassword": "변경할 비번" (선택)
     *  }
     */
    @PutMapping("/me")
    @Operation(summary = "현재 사용자 정보 수정", description = "로그인한 사용자의 정보를 수정합니다.")
    public ResponseEntity<?> updateCurrentUser(
            Authentication authentication,
            @RequestBody Users updateReq
    ) {
        log.info("## 현재 사용자 정보 수정 요청 ##");

        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of(
                        "error", "인증되지 않음",
                        "message", "로그인이 필요합니다."
                ));
            }

            String username = authentication.getName();
            Users user = userService.selectByUsername(username);

            if (user == null) {
                return ResponseEntity.status(404).body(Map.of(
                        "error", "사용자 없음",
                        "message", "사용자 정보를 찾을 수 없습니다."
                ));
            }

            if (updateReq.getName() != null) {
                user.setName(updateReq.getName());
            }
            if (updateReq.getEmail() != null) {
                user.setEmail(updateReq.getEmail());
            }
            if (updateReq.getTel() != null) {
                user.setTel(updateReq.getTel());
            }
            if (updateReq.getBirth() != null) {
                user.setBirth(updateReq.getBirth());
            }
            if (updateReq.getGender() != null) {
                user.setGender(updateReq.getGender());
            }
            if (updateReq.getType() != null) {
                user.setType(updateReq.getType());
            }

            // 새 비밀번호가 들어온 경우에만 변경
            if (updateReq.getNewPassword() != null &&
                !updateReq.getNewPassword().trim().isEmpty()) {
                user.setPassword(updateReq.getNewPassword().trim());
            }

            boolean result = userService.updateById(user);

            if (result) {
                log.info("현재 사용자 정보 수정 성공 - username: {}", username);
                return ResponseEntity.ok("사용자 정보가 수정되었습니다.");
            } else {
                log.warn("현재 사용자 정보 수정 실패 - username: {}", username);
                return ResponseEntity.status(400).body("사용자 정보 수정에 실패했습니다.");
            }

        } catch (Exception e) {
            log.error("현재 사용자 정보 수정 중 예외 발생", e);
            return ResponseEntity.status(500).body(Map.of(
                    "error", "수정 실패",
                    "message", e.getMessage()
            ));
        }
    }

    // DTO 클래스들
    public static class LoginRequest {
        private String username;
        private String password;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }

    public static class RefreshRequest {
        private String refreshToken;

        public String getRefreshToken() {
            return refreshToken;
        }

        public void setRefreshToken(String refreshToken) {
            this.refreshToken = refreshToken;
        }
    }  // join() 있는 서비스

    @PostMapping("/join")
    public ResponseEntity<?> join(@RequestBody Users users) {
        log.info("API 회원가입 요청: {}", users);

        try {
            // 아이디 중복 체크
            Users existing = userService.selectByUsername(users.getUsername());
            if (existing != null) {
                return ResponseEntity
                        .badRequest()
                        .body("이미 존재하는 아이디입니다.");
            }

            if (users.getType() == null || users.getType().isBlank()) {
                users.setType("USER");      // 기본 사용자 타입
            }
            if (users.getEnabled() == null) {
                users.setEnabled(true);     // 기본 활성화
            }

            boolean result = userService.join(users);

            if (result) {
                return ResponseEntity.status(HttpStatus.CREATED).build();
            } else {
                return ResponseEntity
                        .status(HttpStatus.BAD_REQUEST)
                        .body("회원가입 실패");
            }
        } catch (Exception e) {
            log.error("회원가입 중 예외 발생 - username: {}", users.getUsername(), e);
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("서버 오류가 발생했습니다.");
        }
    }

}
