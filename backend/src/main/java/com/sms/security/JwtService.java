package com.sms.security;

import com.sms.entity.AppUser;
import com.sms.repository.AppUserRepository;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class JwtService {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expirationMs:86400000}")
    private long expirationMs;

    private byte[] secretBytes;

    private final AppUserRepository userRepository;

    @PostConstruct
    void init() {
        this.secretBytes = secret.getBytes(StandardCharsets.UTF_8);
    }

    public String generateToken(AppUser user) {
        Instant now = Instant.now();
        return Jwts.builder()
                .setSubject(user.getEmail())
                .claim("role", user.getRole().name())
                .setIssuedAt(Date.from(now))
                .setExpiration(Date.from(now.plusMillis(expirationMs)))
                .signWith(SignatureAlgorithm.HS256, secretBytes)
                .compact();
    }

    public boolean isTokenValid(String token) {
        try {
            var claims = Jwts.parser().setSigningKey(secretBytes).parseClaimsJws(token);
            return claims.getBody().getExpiration().after(new Date());
        } catch (Exception ex) {
            return false;
        }
    }

    public UserDetails getUserDetails(String token) {
        String email = Jwts.parser().setSigningKey(secretBytes).parseClaimsJws(token).getBody().getSubject();
        return userRepository.findByEmail(email).orElseThrow();
    }
}
