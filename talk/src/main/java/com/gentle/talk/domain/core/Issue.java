package com.gentle.talk.domain.core;

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
@TableName("issues")    
@Alias("Issue")        
public class Issue extends Base {

  @TableId(type = IdType.AUTO)
  private Long no;                          // PK
  private String id;                        // UK
  private Long userNo;                      // FK (요청자)
  private Long opponentUserNo;              // 상대방 회원 FK (가입한 경우)
  
  private String conflictSituation;         // 갈등상황
  private String requirements;              // 요구사항
  private String analysisResult;            // 분석결과
  
  private String opponentName;              // 상대방 이름
  private String opponentContact;           // 상대방 연락처
  private String issueCode;                 // 이슈 코드 (비회원 접근용)
  
  private String opponentRequirements;      // 상대방 요구사항(조건)
  private String opponentAnalysisResult;    // 상대방 요구사항 분석결과
  
  private String mediationProposals;        // 중재안 (JSON)
  private String selectedMediationProposal; // 선택된 중재안 (JSON)
  
  private String status;                    // 상태 (대기, 분석중, 분석완료, 상대방 대기, 중재안제시, 협상완료)
  
  // 조인용 필드
  @TableField(exist = false)
  private Users user;                       // 요청자 정보
  
  @TableField(exist = false)
  private Users opponentUser;               // 상대방 회원 정보
  
}
