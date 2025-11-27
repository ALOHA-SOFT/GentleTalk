package com.gentle.talk.domain.etc;

import java.time.LocalDateTime;
import java.util.List;

import org.apache.ibatis.type.Alias;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.gentle.talk.domain.Base;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@TableName("mediation_proposal_logs")    
@Alias("MediationProposalLog")        
public class MediationProposalLog extends Base {

  @TableId(type = IdType.AUTO)
  private Long no;                          // PK
  private String id;                        // UK
  private Long categoryNo;                  // FK (카테고리)
  
  private String conflictSituationHash;     // 갈등상황 해시값
  private String conflictSituation;         // 갈등상황 원문
  private String requirements;              // 요구사항 원문
  private String opponentRequirements;      // 상대방 요구사항 원문
  
  private String mediationProposals;        // 생성된 중재안 (JSON)
  
  private String aiModel;                   // 사용된 AI 모델명
  private Integer aiRequestTokens;          // AI 요청 토큰 수
  private Integer aiResponseTokens;         // AI 응답 토큰 수
  
  private Double similarityScore;           // 유사도 점수
  private Integer reuseCount;               // 재사용 횟수
  private LocalDateTime lastReusedAt;       // 마지막 재사용 일시
  
  private Boolean isFromApi;                // API 생성 여부
  private Long sourceLogNo;                 // 원본 로그 번호
  private Boolean successFeedback;          // 피드백
  
  // 조인용 필드
  @TableField(exist = false)
  private IssueCategory category;           // 카테고리 정보
  
  @TableField(exist = false)
  private Long issueNo;

  @TableField(exist = false)
  private Integer sequence;
}


