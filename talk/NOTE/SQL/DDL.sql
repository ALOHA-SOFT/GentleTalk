-- Active: 1758440462829@@127.0.0.1@3306@gentletalk
SET FOREIGN_KEY_CHECKS = 0;


CREATE DATABASE IF NOT EXISTS `gentletalk` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `gentletalk`;

-- 회원
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
	`no` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'PK',
	`id` VARCHAR(64) NOT NULL UNIQUE COMMENT 'UK',
	`type` VARCHAR(20) NOT NULL COMMENT '회원유형 (사용자, 협상가, 관리자)',
	`username` VARCHAR(100) NOT NULL UNIQUE COMMENT '아이디',
	`password` VARCHAR(100) NOT NULL COMMENT '비밀번호',
	`name` VARCHAR(100) NOT NULL COMMENT '이름',
	`gender` VARCHAR(10) NOT NULL COMMENT '성별',
	`email` VARCHAR(100) NOT NULL COMMENT '이메일',
	`birth` DATE NOT NULL COMMENT '생년월일',
	`tel` VARCHAR(100) NOT NULL COMMENT '전화번호',
	`address` VARCHAR(200) NOT NULL COMMENT '주소',
	`enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '활성화여부',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일자',
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP	COMMENT '수정일자'
			,
	PRIMARY KEY (`no`)
) COMMENT '회원';


-- 회원권한
DROP TABLE IF EXISTS `user_auth`;

CREATE TABLE `user_auth` (
	`no` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'PK',
	`id` VARCHAR(64) NOT NULL UNIQUE COMMENT 'UK',
	`user_no` BIGINT NOT NULL COMMENT 'FK',
	`username` VARCHAR(100) NOT NULL COMMENT '아이디',
	`auth` VARCHAR(100) NOT NULL COMMENT '권한',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일자',
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일자',
	PRIMARY KEY (`no`),
	FOREIGN KEY (`user_no`) REFERENCES `users` (`no`) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '회원권한';


-- 이슈
-- * 하나의 이슈에 여러 개의 분석 요청 가능
-- * 입력정보
-- 1. 갈등상황
-- 2. 요구사항
-- 3. 분석결과
-- 4. 상대방 이름
-- 5. 상대방 연락처
-- 6. 이슈 코드 (가입하지 않아도 상대방이 협상안 확인 가능하도록)
-- 7. 상대방 요구사항(조건)
-- 8. 상대방 요구사항 분석결과
-- 9. 중재안 (나의 분석결과와 상대방 분석결과를 바탕으로 생성, JSON 형식)
--    {"1" : "중재안1", "2" : "중재안2", ...}
-- 10. 선택된 중재안 (JSON, {"1" : "중재안1"})
-- 11. 상태 (대기, 분석중, 분석완료, 상대방 대기, 중재안제시, 협상완료)

DROP TABLE IF EXISTS `issues`;
CREATE TABLE `issues` (
	`no` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'PK',
	`id` VARCHAR(64) NOT NULL UNIQUE COMMENT 'UK',
	`user_no` BIGINT NOT NULL COMMENT 'FK',
	`opponent_user_no` BIGINT COMMENT '상대방 회원 FK',
	`conflict_situation` TEXT NOT NULL COMMENT '갈등상황',
	`requirements` TEXT NOT NULL COMMENT '요구사항',
	`analysis_result` TEXT COMMENT '분석결과',
	`opponent_name` VARCHAR(100) NOT NULL COMMENT '상대방 이름',
	`opponent_contact` VARCHAR(100) NOT NULL COMMENT '상대방 연락처',
	`issue_code` VARCHAR(64) NOT NULL UNIQUE COMMENT '이슈 코드',
	`opponent_requirements` TEXT COMMENT '상대방 요구사항(조건)',
	`opponent_analysis_result` TEXT COMMENT '상대방 요구사항 분석결과',
	`mediation_proposals` JSON COMMENT '중재안',
	`selected_mediation_proposal` JSON COMMENT '선택된 중재안',
	`status` VARCHAR(20) NOT NULL DEFAULT '대기' COMMENT '상태 (대기, 분석중, 분석완료, 분석실패, 상대방대기, 상대방응답, 중재안제시, 협상완료, 협상결렬)',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일자',
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일자',
	PRIMARY KEY (`no`),
	FOREIGN KEY (`user_no`) REFERENCES `users` (`no`) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '이슈';


-- 협상
-- * 하나의 이슈에 대해 여러 번의 협상 가능
-- * 입력정보
-- 1. issue_no (FK)
-- 2. 협상가 user_no (FK)
-- 3. 중재안 (JSON, {"1" : "중재안1", "2" : "중재안2", ...})
-- 4. 협상안 (JSON, {"1" : "협상안1", "2" : "협상안2", ...})
-- 5. 수락일
-- 6. 체결일
-- 7. 상태 (대기, 수락, 체결, 불발, 종료)
DROP TABLE IF EXISTS `negotiations`;

CREATE TABLE `negotiations` (
	`no` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'PK',
	`issue_no` BIGINT NOT NULL COMMENT 'FK',
	`user_no` BIGINT NOT NULL COMMENT 'FK',
	`mediation_proposal` JSON COMMENT '중재안',
	`negotiation_proposal` JSON COMMENT '협상안',
	`accepted_at` TIMESTAMP COMMENT '수락일',
	`finalized_at` TIMESTAMP COMMENT '체결일',
	`status` VARCHAR(20) NOT NULL DEFAULT '대기' COMMENT '상태 (대기, 수락, 체결, 불발, 종료)',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일자',
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일자',
	PRIMARY KEY (`no`),
	FOREIGN KEY (`issue_no`) REFERENCES `issues` (`no`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`user_no`) REFERENCES `users` (`no`) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '협상';


-- 이슈 대분류 (카테고리)
DROP TABLE IF EXISTS `issue_categories`;

CREATE TABLE `issue_categories` (
	`no` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'PK',
	`id` VARCHAR(64) NOT NULL UNIQUE COMMENT 'UK',
	`code` VARCHAR(50) NOT NULL UNIQUE COMMENT '카테고리 코드',
	`name` VARCHAR(100) NOT NULL COMMENT '카테고리명',
	`description` TEXT COMMENT '설명',
	`display_order` INT NOT NULL DEFAULT 0 COMMENT '정렬순서',
	`enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '활성화여부',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일자',
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일자',
	PRIMARY KEY (`no`)
) COMMENT '이슈 카테고리';

-- 대분류 초기 데이터 예시
-- INSERT INTO `issue_categories` (`id`, `code`, `name`, `description`, `display_order`) VALUES
-- (UUID(), 'FAMILY', '가족/이혼', '이혼, 양육권, 재산분할 등', 1),
-- (UUID(), 'BUSINESS', '비즈니스', '계약분쟁, 파트너십, 거래 등', 2),
-- (UUID(), 'REAL_ESTATE', '부동산', '임대차, 매매, 경계 등', 3),
-- (UUID(), 'NEIGHBOR', '이웃분쟁', '층간소음, 주차, 경계 등', 4),
-- (UUID(), 'LABOR', '노동/직장', '임금, 해고, 근로조건 등', 5),
-- (UUID(), 'CONSUMER', '소비자분쟁', '환불, 하자, 서비스 불만 등', 6),
-- (UUID(), 'OTHER', '기타', '기타 협상 사항', 99);

-- 카테고리 대분류
DROP TABLE IF EXISTS `issue_category_groups`;

CREATE TABLE `issue_category_groups` (
	`no` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'PK',
	`id` VARCHAR(64) NOT NULL UNIQUE COMMENT 'UK',
	`issue_categories_no` BIGINT NOT NULL COMMENT 'FK',
	`name` VARCHAR(100) NOT NULL COMMENT '대분류명',
	`description` TEXT COMMENT '설명',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일자',
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일자',
	PRIMARY KEY (`no`),
	FOREIGN KEY (`issue_categories_no`) REFERENCES `issue_categories` (`no`) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '이슈 카테고리 그룹';



-- 이슈 카테고리 매핑
DROP TABLE IF EXISTS `issue_category_mapping`;

CREATE TABLE `issue_category_mapping` (
	`no` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'PK',
	`issue_no` BIGINT NOT NULL COMMENT 'FK',
	`category_no` BIGINT NOT NULL COMMENT 'FK',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일자',
	PRIMARY KEY (`no`),
	FOREIGN KEY (`issue_no`) REFERENCES `issues` (`no`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`category_no`) REFERENCES `issue_categories` (`no`) ON DELETE CASCADE ON UPDATE CASCADE,
	UNIQUE KEY `uk_issue_category` (`issue_no`, `category_no`)
) COMMENT '이슈-카테고리 매핑';


-- 협상가(중재자) 전문 정보
DROP TABLE IF EXISTS `negotiator_profiles`;

CREATE TABLE `negotiator_profiles` (
	`no` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'PK',
	`id` VARCHAR(64) NOT NULL UNIQUE COMMENT 'UK',
	`user_no` BIGINT NOT NULL UNIQUE COMMENT 'FK (협상가 회원)',
	`introduction` TEXT COMMENT '소개글',
	`career_years` INT NOT NULL DEFAULT 0 COMMENT '경력 연수',
	`total_cases` INT NOT NULL DEFAULT 0 COMMENT '총 처리 건수',
	`success_cases` INT NOT NULL DEFAULT 0 COMMENT '성공 건수',
	`success_rate` DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT '성공률 (%)',
	`avg_resolution_days` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '평균 해결 소요일',
	`rating_avg` DECIMAL(3,2) NOT NULL DEFAULT 0.00 COMMENT '평균 평점 (5점 만점)',
	`rating_count` INT NOT NULL DEFAULT 0 COMMENT '평가 건수',
	`certifications` JSON COMMENT '자격증 정보 [{"name":"자격증명", "issuer":"발급기관", "date":"취득일"}]',
	`specialties` JSON COMMENT '전문 분야 (카테고리 코드 배열) ["FAMILY", "BUSINESS"]',
	`profile_image_url` VARCHAR(500) COMMENT '프로필 이미지 URL',
	`enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '활성화여부',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일자',
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일자',
	PRIMARY KEY (`no`),
	FOREIGN KEY (`user_no`) REFERENCES `users` (`no`) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '협상가 프로필';


-- 중재안 로그 (AI API 캐싱 및 재사용)
-- * AI API로 생성된 중재안을 저장하여 유사한 케이스에서 재활용
-- * 비용 절감 및 응답 속도 향상
DROP TABLE IF EXISTS `mediation_proposal_logs`;

CREATE TABLE `mediation_proposal_logs` (
	`no` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'PK',
	`id` VARCHAR(64) NOT NULL UNIQUE COMMENT 'UK',
	`category_no` BIGINT NOT NULL COMMENT 'FK (카테고리)',
	`conflict_situation_hash` VARCHAR(64) NOT NULL COMMENT '갈등상황 해시값 (유사도 검색용)',
	`conflict_situation` TEXT NOT NULL COMMENT '갈등상황 원문',
	`requirements` TEXT NOT NULL COMMENT '요구사항 원문',
	`opponent_requirements` TEXT COMMENT '상대방 요구사항 원문',
	`mediation_proposals` JSON NOT NULL COMMENT '생성된 중재안 [{"no":1, "content":"중재안1"}, ...]',
	`ai_model` VARCHAR(100) COMMENT '사용된 AI 모델명',
	`ai_request_tokens` INT COMMENT 'AI 요청 토큰 수',
	`ai_response_tokens` INT COMMENT 'AI 응답 토큰 수',
	`similarity_score` DECIMAL(5,4) COMMENT '유사도 점수 (재사용 시)',
	`reuse_count` INT NOT NULL DEFAULT 0 COMMENT '재사용 횟수',
	`last_reused_at` TIMESTAMP COMMENT '마지막 재사용 일시',
	`is_from_api` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'API 생성 여부 (1:API, 0:캐시재사용)',
	`source_log_no` BIGINT COMMENT '원본 로그 번호 (재사용된 경우)',
	`success_feedback` TINYINT(1) COMMENT '피드백 (1:성공, 0:실패, NULL:미평가)',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일자',
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일자',
	PRIMARY KEY (`no`),
	FOREIGN KEY (`category_no`) REFERENCES `issue_categories` (`no`) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (`source_log_no`) REFERENCES `mediation_proposal_logs` (`no`) ON DELETE SET NULL ON UPDATE CASCADE,
	INDEX `idx_category_hash` (`category_no`, `conflict_situation_hash`),
	INDEX `idx_reuse_count` (`reuse_count` DESC),
	INDEX `idx_created_at` (`created_at` DESC)
) COMMENT '중재안 로그 (AI 캐싱)';




SET FOREIGN_KEY_CHECKS = 1;