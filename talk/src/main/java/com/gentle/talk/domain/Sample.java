package com.gentle.talk.domain;

import org.apache.ibatis.type.Alias;

import com.baomidou.mybatisplus.annotation.TableName;

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
@TableName("sample")    // 테이블명 (Mybatis plus)
@Alias("Sample")        // 별칭 (Mybatis package 생략용 - Mapper에서 사용)
public class Sample extends Base {

  private String name;        // 이름


}
