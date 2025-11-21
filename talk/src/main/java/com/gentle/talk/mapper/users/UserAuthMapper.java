package com.gentle.talk.mapper.users;

import org.apache.ibatis.annotations.Mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gentle.talk.domain.users.UserAuth;

@Mapper
public interface UserAuthMapper extends BaseMapper<UserAuth> {

}
