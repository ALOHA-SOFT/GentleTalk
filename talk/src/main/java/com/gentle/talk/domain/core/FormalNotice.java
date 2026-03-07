package com.gentle.talk.domain.core;

import java.util.Map;

import org.apache.ibatis.type.Alias;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
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
@TableName("formal_notice")
@Alias("FormalNotice")
public class FormalNotice extends Base {

    @TableId(type = IdType.AUTO)
    private Long no; // PK
    private String id; // UK
    private Long userNo; // FK (요청자)
    private Long opponentUserNo; // 상대방 회원 FK (가입한 경우)

    private String categoryKey; // 카테고리 키 (ex: "debt_collection", "contract_termination")

    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> categoryData; // 카테고리별 추가 데이터 (ex: 금액, 날짜 등)

    // 발신자 정보
    private String senderName;
    private String senderPhone;
    private String senderAddress;

    // 수신자 정보
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;

    private String previewText; // 생성된 내용증명 텍스트 (미리보기용)

    private String status; // 상태 (대기, 분석중, 분석완료)
    private String flag; // 최종 버전 여부 (Y: 최종 저장본, N: 임시/이전 버전)

    // 조인용 필드
    @TableField(exist = false)
    private Users user; // 요청자 정보

    @TableField(exist = false)
    private Users opponentUser; // 상대방 회원 정보

    @TableField(exist = false)
    private String username; // 요청자 이름 (조인용)

}