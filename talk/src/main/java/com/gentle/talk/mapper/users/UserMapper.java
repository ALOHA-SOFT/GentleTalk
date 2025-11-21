package com.gentle.talk.mapper.users;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gentle.talk.domain.common.QueryParams;
import com.gentle.talk.domain.users.Users;

@Mapper
public interface UserMapper extends BaseMapper<Users> {

  // 회원조회
  public Users selectByUsername(String username);
  
  // 페이징 조회
  public List<Users> listWithParams(QueryParams queryParams);
  
  // 이름과 이메일로 사용자 찾기
  public Users findByNameAndEmail(String name, String email);
  
  // 사용자명과 이메일로 사용자 찾기
  public Users findByUsernameAndEmail(String username, String email);
  
}
