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
@TableName("issue_mediation_log_mapping")    
@Alias("IssueMediationLogMapping")        
public class IssueMediationLogMapping extends Base {

  @TableId(type = IdType.AUTO)
  private Long no;                      // PK
  private Long issueNo;                 // FK (이슈)
  private Long mediationLogNo;          // FK (중재안 로그)
  
}
