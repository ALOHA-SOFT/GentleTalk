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
@TableName("issue_category_mapping")    
@Alias("IssueCategoryMapping")        
public class IssueCategoryMapping extends Base {

  @TableId(type = IdType.AUTO)
  private Long no;                  // PK
  private Long issueNo;             // FK (이슈)
  private Long categoryNo;          // FK (카테고리)
  
}
