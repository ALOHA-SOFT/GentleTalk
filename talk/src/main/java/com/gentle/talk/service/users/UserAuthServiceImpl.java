package com.gentle.talk.service.users;

import org.springframework.stereotype.Service;
import com.gentle.talk.domain.users.UserAuth;
import com.gentle.talk.mapper.users.UserAuthMapper;
import com.gentle.talk.service.BaseServiceImpl;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class UserAuthServiceImpl extends BaseServiceImpl<UserAuth, UserAuthMapper> implements UserAuthService {

}
