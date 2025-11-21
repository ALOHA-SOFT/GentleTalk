package com.gentle.talk.domain;

import java.util.Date;
import java.util.UUID;

import org.apache.ibatis.type.Alias;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@AllArgsConstructor
// @Builder
@TableName("base")    // 테이블명 (Mybatis plus)
@Alias("Base")        // 별칭 (Mybatis package 생략용 - Mapper에서 사용)
public class Base {

    @TableId(type = IdType.AUTO)        // PK 자동증가 (Mybatis plus - insert 에서 사용)
    private Long no;                    // PK
    private String id;                  // ID
    private Date createdAt;             // 생성일
    private Date updatedAt;             // 수정일

    public Base() {
        this.id = UUID.randomUUID().toString();         // UUID로 ID 생성
    }

}
