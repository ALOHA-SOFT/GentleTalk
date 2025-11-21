package com.gentle.talk.domain.etc;

import org.apache.ibatis.type.Alias;

import com.baomidou.mybatisplus.annotation.IdType;
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
@TableName("issue_categories")    
@Alias("IssueCategory")        
public class IssueCategory extends Base {

  @TableId(type = IdType.AUTO)
  private Long no;                  // PK
  private String id;                // UK
  private String code;              // 카테고리 코드
  private String name;              // 카테고리명
  private String description;       // 설명
  private Integer displayOrder;     // 정렬순서
  private Boolean enabled;          // 활성화여부
  
}
