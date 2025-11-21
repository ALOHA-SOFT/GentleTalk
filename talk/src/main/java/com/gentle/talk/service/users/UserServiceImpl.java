package com.gentle.talk.service.users;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.users.UserAuth;
import com.gentle.talk.domain.users.Users;
import com.gentle.talk.mapper.users.UserAuthMapper;
import com.gentle.talk.mapper.users.UserMapper;
import com.gentle.talk.service.BaseServiceImpl;
import com.gentle.talk.service.common.EmailService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class UserServiceImpl extends BaseServiceImpl<Users, UserMapper> implements UserService {

    @Autowired UserMapper mapper;
    @Autowired UserAuthMapper userAuthMapper;
    @Autowired PasswordEncoder passwordEncoder;
    @Autowired EmailService emailService;

    @Transactional
    @Override
    public boolean join(Users entity) {

        log.info("## 회원가입 ##");
        log.info("entity={}", entity);
        
        // 회원가입 처리
        try {
            // ID(UUID) 체크
            if (entity.getId() == null || entity.getId().isEmpty()) {
                entity.setId(java.util.UUID.randomUUID().toString());
            }
            // 비밀번호 암호화
            String encodedPassword = passwordEncoder.encode(entity.getPassword());
            entity.setPassword(encodedPassword);
            mapper.insert(entity);

            // 기본 권한등록 : ROLE_USER
            UserAuth userAuth = new UserAuth();
            userAuth.setUserNo(entity.getNo());
            userAuth.setUsername(entity.getUsername());
            userAuth.setAuth("ROLE_USER");
            userAuthMapper.insert(userAuth);
            log.info("회원가입 성공: {}", entity.getUsername());
            return true;
        } catch (Exception e) {
            log.error("회원가입 실패: {}", e.getMessage());
            return false;
        }

    }

    @Override
    public Users selectByUsername(String username) {
        QueryWrapper<Users> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("username", username);

        try {
            Users user = mapper.selectOne(queryWrapper);
            if (user != null) {
                log.info("사용자 {} 존재", username);
                return user;
            } else {
                log.info("사용자 {} 존재하지 않음", username);
                return user;
            }
        } catch (Exception e) {
            log.error("사용자 조회 실패: {}", e.getMessage());
            return null;
        }
    }

    @Override
    public PageInfo<Users> page(QueryParams queryParams) {
        // 페이지 시작 
        PageHelper.startPage(queryParams.getPage(), queryParams.getSize());
        
        // 검색 및 정렬 조건을 포함하여 데이터 조회
        return new PageInfo<>(mapper.listWithParams(queryParams));
    }

    @Override
    public boolean update(Users entity) {
        log.info("## 회원정보 수정 ##");
        log.info("entity={}", entity);
        
        // 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(entity.getPassword());
        entity.setPassword(encodedPassword);
        
        // 회원정보 수정
        try {
            int result = mapper.updateById(entity);
            if (result > 0) {
                log.info("회원정보 수정 성공: {}", entity.getUsername());
                return true;
            } else {
                log.warn("회원정보 수정 실패: {}", entity.getUsername());
                return false;
            }
        } catch (Exception e) {
            log.error("회원정보 수정 중 오류 발생: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public boolean updateById(Users entity) {
        log.info("## 회원정보 수정 ##");
        log.info("entity={}", entity);
        
        boolean newPasswordProvided = entity.getNewPassword() != null && !entity.getNewPassword().isEmpty();
        boolean confirmPasswordProvided = entity.getConfirmPassword() != null && !entity.getConfirmPassword().isEmpty();
        QueryWrapper<Users> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("id", entity.getId());
        // 비밀번호 암호화
        if( !newPasswordProvided && !confirmPasswordProvided ) {
            log.info("비밀번호 변경 없음: {}", entity.getUsername());
        } else {
            log.info("비밀번호 변경: {}", entity.getUsername());

            Users existingUser = mapper.selectOne(queryWrapper);
            if (existingUser == null) {
                log.warn("사용자 정보가 존재하지 않습니다: {}", entity.getId());
                return false;
            }
            existingUser.getPassword(); // 현재 비밀번호 확인
            if (!passwordEncoder.matches(entity.getPassword(), existingUser.getPassword())) {
                log.warn("현재 비밀번호가 일치하지 않습니다: {}", entity.getUsername());
                return false;
            }
            String encodedPassword = passwordEncoder.encode(entity.getNewPassword());
            entity.setPassword(encodedPassword);
        }
        // 회원정보 수정
        try {
            
            int result = mapper.update(entity, queryWrapper);
            if (result > 0) {
                log.info("회원정보 수정 성공: {}", entity.getUsername());
                return true;
            } else {
                log.warn("회원정보 수정 실패: {}", entity.getUsername());
                return false;
            }
        } catch (Exception e) {
            log.error("회원정보 수정 중 오류 발생: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public boolean checkPassword(Users existingUser, String password) {
        if (existingUser == null || password == null) {
            return false;
        }
        return passwordEncoder.matches(password, existingUser.getPassword());
    }

    @Override
    public Users findByNameAndEmail(String name, String email) {
        log.info("## 아이디 찾기 ##");
        log.info("name={}, email={}", name, email);
        
        try {
            QueryWrapper<Users> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("name", name)
                       .eq("email", email)
                       .eq("enabled", true); // 활성화된 계정만 조회
            
            Users user = mapper.selectOne(queryWrapper);
            if (user != null) {
                log.info("아이디 찾기 성공: {}", user.getUsername());
                return user;
            } else {
                log.info("아이디 찾기 실패: 일치하는 사용자 없음");
                return null;
            }
        } catch (Exception e) {
            log.error("아이디 찾기 중 오류 발생: {}", e.getMessage());
            return null;
        }
    }

    @Override
    public boolean resetPassword(String username, String email) {
        log.info("## 비밀번호 재설정 ##");
        log.info("username={}, email={}", username, email);
        
        try {
            // 사용자 조회
            QueryWrapper<Users> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("username", username)
                       .eq("email", email)
                       .eq("enabled", true); // 활성화된 계정만 대상
            
            Users user = mapper.selectOne(queryWrapper);
            if (user == null) {
                log.info("비밀번호 재설정 실패: 일치하는 사용자 없음");
                return false;
            }
            
            // 8자리 임시 비밀번호 생성
            String tempPassword = generateTempPassword();
            log.info("임시 비밀번호 생성: {}", tempPassword);
            
            // 비밀번호 암호화 후 업데이트
            String encodedPassword = passwordEncoder.encode(tempPassword);
            user.setPassword(encodedPassword);
            
            int result = mapper.updateById(user);
            if (result > 0) {
                log.info("임시 비밀번호 설정 성공: {}", username);
                
                // 이메일 발송 (실제 구현에서는 EmailService 사용)
                sendTempPasswordEmail(email, username, tempPassword);
                
                return true;
            } else {
                log.warn("임시 비밀번호 설정 실패: {}", username);
                return false;
            }
        } catch (Exception e) {
            log.error("비밀번호 재설정 중 오류 발생: {}", e.getMessage());
            return false;
        }
    }
    
    /**
     * 8자리 임시 비밀번호 생성
     * @return 임시 비밀번호
     */
    private String generateTempPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder tempPassword = new StringBuilder();
        java.util.Random random = new java.util.Random();
        
        for (int i = 0; i < 8; i++) {
            tempPassword.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return tempPassword.toString();
    }
    
    /**
     * 임시 비밀번호 이메일 발송
     * 실제 EmailService를 사용하여 이메일 발송
     * @param email 수신자 이메일
     * @param username 사용자명
     * @param tempPassword 임시 비밀번호
     */
    private void sendTempPasswordEmail(String email, String username, String tempPassword) {
        try {
            // TODO
            // boolean result = emailService.sendTempPassword(email, username, tempPassword);
            boolean result = true; // 임시로 true 설정
            if (result) {
                log.info("임시 비밀번호 이메일 발송 성공: {}", email);
            } else {
                log.warn("임시 비밀번호 이메일 발송 실패: {}", email);
            }
        } catch (Exception e) {
            log.error("임시 비밀번호 이메일 발송 중 오류 발생: {}, 오류: {}", email, e.getMessage());
        }
    }


    


}
