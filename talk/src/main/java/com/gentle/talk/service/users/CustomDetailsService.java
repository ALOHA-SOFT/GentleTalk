package com.gentle.talk.service.users;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.gentle.talk.domain.users.CustomUser;
import com.gentle.talk.domain.users.Users;
import com.gentle.talk.mapper.users.UserMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class CustomDetailsService implements UserDetailsService {

  @Autowired private UserMapper userMapper;

    /**
     * 사용자 정보 조회
     * username: 사용자 이메일
     * return: UserDetails
     */
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        log.info("username: " + username);
        // MyBaits 사용해서 사용자 정보 조회
        Users user = userMapper.selectByUsername(username);
        log.info("user: " + user);
        if( user == null ) {
            throw new UsernameNotFoundException("사용자를 찾을 수 없습니다." + username);
        }

        // 🔐 CustomUser ➡ UserDetails
        CustomUser customUser = new CustomUser(user);
        return customUser;
    }
  
}
