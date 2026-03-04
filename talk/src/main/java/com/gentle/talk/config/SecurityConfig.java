package com.gentle.talk.config;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.BadSqlGrammarException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.rememberme.JdbcTokenRepositoryImpl;
import org.springframework.security.web.authentication.rememberme.PersistentTokenRepository;

import com.gentle.talk.security.handler.CustomAccessDeniedHandler;
import com.gentle.talk.security.handler.CustomAuthenticationSuccessHandler;
import com.gentle.talk.security.handler.CustomLogoutSuccessHandler;
import com.gentle.talk.security.handler.CustomRememberMeServices;
import com.gentle.talk.security.handler.LoginFailureHandler;
import com.gentle.talk.security.handler.LoginSuccessHandler;
import com.gentle.talk.security.jwt.JwtAuthenticationFilter;
import com.gentle.talk.service.users.CustomDetailsService;

import lombok.extern.slf4j.Slf4j;


@Slf4j
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(securedEnabled = true, prePostEnabled = true)
public class SecurityConfig {

    @Autowired private DataSource dataSource;
    @Autowired private CustomDetailsService customDetailsService;
    @Autowired private LoginSuccessHandler loginSuccessHandler;
    @Autowired private CustomAuthenticationSuccessHandler customAuthenticationSuccessHandler;
    @Autowired private CustomLogoutSuccessHandler logoutSuccessHandler;
    @Autowired private LoginFailureHandler loginFailureHandler;
    @Autowired private CustomAccessDeniedHandler customAccessDeniedHandler;
    @Autowired private JwtAuthenticationFilter jwtAuthenticationFilter;


    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        // HTTP 보안 설정 시작
        http
                // CORS 활성화
                .cors(cors -> cors.configure(http))
                .authorizeHttpRequests(authorize -> authorize
                                // JWT 인증 API는 모두 허용
                                .requestMatchers("/api/v1/auth/**").permitAll()
                                // Swagger 관련 경로 허용
                                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                                .requestMatchers("/static/**").permitAll()              // "/static/**" 경로에 대한 모든 요청을 허용
                                .requestMatchers("/admin/**").hasRole("ADMIN")      // "/admin/**" 경로에 대한 요청은 ADMIN 권한 필요
                                .requestMatchers("/users/**").hasRole("USER")      // "/users/**" 경로에 대한 요청은 USER 권한 필요
                                .requestMatchers("/my/**").hasRole("USER")      // "/users/**" 경로에 대한 요청은 USER 권한 필요
                                .requestMatchers("/**").permitAll()             // 루트 경로에 대한 모든 요청을 허용
                                .requestMatchers("/api/**").permitAll()
                .anyRequest().authenticated()                            // 주석 처리된 부분: 모든 다른 요청은 인증 필요
                )
                // JWT 필터 추가 (UsernamePasswordAuthenticationFilter 앞에)
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                // 세션 정책 설정 - API는 Stateless, 일반 웹은 세션 사용
                .sessionManagement(session -> session
                                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                )
                // 로그인 설정
                .formLogin(form -> form
                                .usernameParameter("username")
                                .passwordParameter("password")
                                .loginProcessingUrl("/login") // 로그인 처리 URL
                                .loginPage("/login") // 사용자 정의 로그인 페이지
                                .successHandler(loginSuccessHandler)
                                .failureHandler(loginFailureHandler)
                                .permitAll()
                )
                // 사용자 정의 UserDetailsService 설정
                .userDetailsService(customDetailsService)
                // 자동 로그인 설정
                // - 자동 로그인 기본 파라미터 : remember-me
                .rememberMe(rememberMe -> rememberMe
                                .key("ckauto")
                                .rememberMeServices(customRememberMeServices())
                                .tokenRepository(tokenRepository())
                                .userDetailsService(customDetailsService)
                                .authenticationSuccessHandler(customAuthenticationSuccessHandler)
                                .tokenValiditySeconds(60 * 60 * 24 * 30) // 30일
                )
                // 로그아웃 설정
                .logout(logout -> logout
                                .logoutUrl("/logout") // 로그아웃 URL
                                .logoutSuccessHandler(logoutSuccessHandler)
                                .permitAll()
                )
                // 예외 처리 설정
                .exceptionHandling(exception -> exception
                                // 접근 거부 처리자 설정
                                .accessDeniedHandler(customAccessDeniedHandler)
                )
                // Headers 설정 - iframe 허용
                .headers(headers -> headers
                                .frameOptions(frameOptions -> frameOptions.sameOrigin()) // 같은 도메인에서 iframe 허용
                )
            // CSRF 설정 - API 경로는 CSRF 예외 처리
            .csrf(csrf -> csrf
                .ignoringRequestMatchers("/CHEditor/upload", "/api/**")
            )
            ;
        
        return http.build(); // 설정을 기반으로 SecurityFilterChain 객체를 빌드하여 반환
    }

    /**
     * 🍃 AuthenticationManager 빈 등록 (JWT 인증용)
     * @return
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }



   /**
	 * 🍃 암호화 방식 빈 등록
	 * @return
	*/
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }


     /**
    * 🍃 자동 로그인 저장소 빈 등록
    * ✅ 데이터 소스
    * ⭐ persistent_logins 테이블 생성
            create table persistent_logins (
                username varchar(64) not null
                , series varchar(64) primary key
                , token varchar(64) not null
                , last_used timestamp not null
            );
    * 🔄 자동 로그인 프로세스
    * ✅ 로그인 시 
    *     ➡ 👩‍💼(ID, 시리즈, 토큰) 저장
    * ✅ 로그아웃 시, 
    *     ➡ 👩‍💼(ID, 시리즈, 토큰) 삭제
    * @return
    */
    @Bean
    public PersistentTokenRepository tokenRepository() {
        // JdbcTokenRepositoryImpl : 토큰 저장 데이터 베이스를 등록하는 객체
        JdbcTokenRepositoryImpl repositoryImpl = new JdbcTokenRepositoryImpl();
        // ✅ 토큰 저장소를 사용하는 데이터 소스 지정
        // - 시큐리티가 자동 로그인 프로세스를 처리하기 위한 DB를 지정합니다.
        repositoryImpl.setDataSource(dataSource);   
        // 서버 실행 시, 자동 로그인 테이블 자동 생성
        // repositoryImpl.setCreateTableOnStartup(true);

        // persistent_logins 테이블 생성
        try {
            JdbcTemplate jdbcTemplate =  repositoryImpl.getJdbcTemplate();
            if( jdbcTemplate == null ) {
                jdbcTemplate = new JdbcTemplate(dataSource);
                repositoryImpl.setJdbcTemplate(jdbcTemplate);
            }
            jdbcTemplate.execute(JdbcTokenRepositoryImpl.CREATE_TABLE_SQL);
        } 
        catch (BadSqlGrammarException e) {
            log.error("persistent_logins 테이블이 이미 존재합니다.");   
        }
        catch (Exception e) {
            log.error("자동 로그인 테이블 생성 중 , 예외 발생");
        }
        return repositoryImpl;
    }


    /**
     * 🍃 사용자 정의 자동 로그인 서비스 빈 등록
     * @return
     */
    @Bean
    public CustomRememberMeServices customRememberMeServices() {
        return new CustomRememberMeServices("ckauto", customDetailsService, tokenRepository());
    }
  
}
