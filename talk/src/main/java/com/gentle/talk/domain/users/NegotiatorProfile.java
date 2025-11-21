package com.gentle.talk.domain.users;

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
@TableName("negotiator_profiles")    
@Alias("NegotiatorProfile")        
public class NegotiatorProfile extends Base {

  @TableId(type = IdType.AUTO)
  private Long no;                            // PK
  private String id;                          // UK
  private Long userNo;                        // FK (협상가 회원)
  
  private String introduction;                // 소개글
  private Integer careerYears;                // 경력 연수
  private Integer totalCases;                 // 총 처리 건수
  private Integer successCases;               // 성공 건수
  private Double successRate;                 // 성공률 (%)
  private Double avgResolutionDays;           // 평균 해결 소요일
  private Double ratingAvg;                   // 평균 평점 (5점 만점)
  private Integer ratingCount;                // 평가 건수
  
  private String certifications;              // 자격증 정보 (JSON)
  private String specialties;                 // 전문 분야 (JSON - 카테고리 코드 배열)
  private String profileImageUrl;             // 프로필 이미지 URL
  private Boolean enabled;                    // 활성화여부
  
  // 조인용 필드
  @TableField(exist = false)
  private Users user;                         // 협상가 회원 정보
  
}
