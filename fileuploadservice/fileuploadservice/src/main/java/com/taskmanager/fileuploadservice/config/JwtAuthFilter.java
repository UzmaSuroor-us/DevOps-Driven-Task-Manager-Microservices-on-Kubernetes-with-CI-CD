package com.taskmanager.fileuploadservice.config;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.Key;

@Component
public class JwtAuthFilter implements Filter {

    private final String secretKey = "MzJieXRlc2xvbmdzZWNyZXRrZXlmb3Jqd3QxMjM0NTY=";
    private final long expiration = 3600000; // 1 hour

    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getRequestURI();

        // Allow public endpoints without token
        if (path.startsWith("/auth")) {
            chain.doFilter(request, response);
            return;
       }
               String authHeader = req.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token);
            } catch (JwtException e) {
                e.printStackTrace(); // Optional: log for debugging
                res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or expired token");
                return;
            }
        } else {
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Missing token");
            return;
        }

        chain.doFilter(request, response);
    }
}
