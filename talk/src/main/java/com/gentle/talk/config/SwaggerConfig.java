package com.gentle.talk.config;

import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;


@Configuration
public class SwaggerConfig {
 
    // group1 : /api/v1/**
    @Bean
    public GroupedOpenApi publicApi() {
      return GroupedOpenApi.builder()
          .group("public")
          .pathsToMatch("/**")
          .build();
    }

    // group2 : /api/admin/v1/**
    @Bean
    public GroupedOpenApi adminApi() {
        return GroupedOpenApi.builder()
            .group("admin")
            .pathsToMatch("/api/admin/v1/**")
            .build();
    }

    @Bean
    public OpenAPI springShopOpenAPI() {
        // JWT Security Scheme 정의
        String jwtSchemeName = "bearerAuth";
        SecurityRequirement securityRequirement = new SecurityRequirement().addList(jwtSchemeName);
        
        Components components = new Components()
                .addSecuritySchemes(jwtSchemeName, new SecurityScheme()
                        .name(jwtSchemeName)
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")
                        .description("JWT 토큰을 입력하세요 (Bearer 제외)")
                );
        
        return new OpenAPI()
                .info(new Info()
                        .title("GentleTalk API")
                        .description("GentleTalk 협상 중계 앱 API 명세서\n\n" +
                                "### JWT 인증 사용 방법\n" +
                                "1. `/api/v1/auth/login` 엔드포인트로 로그인하여 JWT 토큰 발급\n" +
                                "2. 우측 상단의 'Authorize' 버튼 클릭\n" +
                                "3. 발급받은 accessToken 값을 입력 (Bearer 제외)\n" +
                                "4. 인증이 필요한 API 테스트")
                        .version("v0.0.1"))
                .components(components)
                .addSecurityItem(securityRequirement);
    }

    
}