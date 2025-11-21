package com.gentle.talk.domain.core;

import java.time.LocalDateTime;

import org.apache.ibatis.type.Alias;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.gentle.talk.domain.Base;
import com.gentle.talk.domain.users.Users;

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
@TableName("negotiations")    
@Alias("Negotiation")        
public class Negotiation extends Base {

  @TableId(type = IdType.AUTO)
  private Long no;                      // PK
  private Long issueNo;                 // FK (이슈)
  private Long userNo;                  // FK (협상가)
  
  private String mediationProposal;     // 중재안 (JSON)
  private String negotiationProposal;   // 협상안 (JSON)
  
  private LocalDateTime acceptedAt;     // 수락일
  private LocalDateTime finalizedAt;    // 체결일
  
  private String status;                // 상태 (대기, 수락, 체결, 불발, 종료)
  
  // 조인용 필드
  @TableField(exist = false)
  private Issue issue;                  // 이슈 정보
  
  @TableField(exist = false)
  private Users negotiator;             // 협상가 정보
  
}
