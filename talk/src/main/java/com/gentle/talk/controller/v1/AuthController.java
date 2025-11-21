package com.gentle.talk.controller.v1;

import com.gentle.talk.domain.users.Users;
import com.gentle.talk.security.jwt.JwtTokenProvider;
import com.gentle.talk.service.users.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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

            Map<String, Object> response = new HashMap<>();
            response.put("user", Map.of(
                    "no", user.getNo(),
                    "username", user.getUsername(),
                    "name", user.getName(),
                    "email", user.getEmail(),
                    "tel", user.getTel(),
                    "enabled", user.getEnabled()
            ));

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("현재 사용자 정보 조회 실패", e);
            return ResponseEntity.status(500).body(Map.of(
                    "error", "조회 실패",
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
    }
}
