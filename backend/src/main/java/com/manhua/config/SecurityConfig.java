package com.manhua.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * 安全配置类
 * 
 * @author ManhuaReader
 * @version 1.0.0
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Value("${manhua.security.enable-auth:false}")
    private boolean enableAuth;

    @Value("${manhua.security.enable-cors:true}")
    private boolean enableCors;

    @Value("${manhua.security.allowed-origins:http://localhost:3000,http://localhost:5173}")
    private List<String> allowedOrigins;

    /**
     * 配置安全过滤器链
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 禁用CSRF（因为我们使用JWT）
            .csrf(AbstractHttpConfigurer::disable)
            
            // 配置CORS
            .cors(cors -> {
                if (enableCors) {
                    cors.configurationSource(corsConfigurationSource());
                } else {
                    cors.disable();
                }
            })
            
            // 配置会话管理
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            
            // 配置授权规则
            .authorizeHttpRequests(authz -> {
                if (enableAuth) {
                    authz
                        // 公开端点
                        .requestMatchers(
                            "/api/auth/**",
                            "/api/public/**",
                            "/actuator/health",
                            "/actuator/info",
                            "/h2-console/**",
                            "/swagger-ui/**",
                            "/v3/api-docs/**",
                            "/error"
                        ).permitAll()
                        
                        // 静态资源
                        .requestMatchers(
                            "/static/**",
                            "/css/**",
                            "/js/**",
                            "/images/**",
                            "/favicon.ico"
                        ).permitAll()
                        
                        // 其他请求需要认证
                        .anyRequest().authenticated();
                } else {
                    // 如果未启用认证，允许所有请求
                    authz.anyRequest().permitAll();
                }
            })
            
            // 配置异常处理
            .exceptionHandling(exceptions -> exceptions
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setStatus(401);
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write(
                        "{\"error\":\"Unauthorized\",\"message\":\"" + 
                        authException.getMessage() + "\"}"
                    );
                })
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    response.setStatus(403);
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write(
                        "{\"error\":\"Forbidden\",\"message\":\"" + 
                        accessDeniedException.getMessage() + "\"}"
                    );
                })
            )
            
            // 配置H2控制台（开发环境）
            .headers(headers -> headers
                .frameOptions().sameOrigin()
            );

        return http.build();
    }

    /**
     * CORS配置源
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // 允许的源
        if (allowedOrigins != null && !allowedOrigins.isEmpty()) {
            configuration.setAllowedOrigins(allowedOrigins);
        } else {
            configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        }
        
        // 允许的方法
        configuration.setAllowedMethods(Arrays.asList(
            "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"
        ));
        
        // 允许的头部
        configuration.setAllowedHeaders(Arrays.asList("*"));
        
        // 允许凭证
        configuration.setAllowCredentials(true);
        
        // 预检请求缓存时间
        configuration.setMaxAge(3600L);
        
        // 暴露的头部
        configuration.setExposedHeaders(Arrays.asList(
            "Authorization", "Content-Type", "X-Total-Count", "X-Page-Count"
        ));
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        
        return source;
    }

    /**
     * 密码编码器
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}