package com.gentle.talk.domain.users;

import java.util.List;

import org.apache.ibatis.type.Alias;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.gentle.talk.domain.Base;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;


@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@TableName("users")    
@Alias("Users")        
public class Users extends Base {


  @TableId(type = IdType.AUTO)                // PK 자동증가 (Mybatis plus - insert 에서 사용)
  private Long no;                            // PK
  private String id;                          // 사용자 ID (로그인용)

  private String username; // 아이디  
  private String password; // 비밀번호
  @TableField(exist = false) private String newPassword;        // 새 비밀번호
  @TableField(exist = false) private String confirmPassword;    // 새 비밀번호 확인


  private String name;     // 이름
  private String tel;      // 전화번호
  private String email;    // 이메일
  private Boolean enabled; // 계정 활성화 여부

  @TableField(exist = false)
  List<UserAuth> authList; // 권한 목록
  
}
