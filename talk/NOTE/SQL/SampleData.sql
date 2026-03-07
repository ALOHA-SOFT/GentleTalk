-- Active: 1772602212353@@127.0.0.1@3306@gentletalk
INSERT INTO users
(id, type, username, password, name, gender, email, birth, tel)
VALUES
(UUID(), 'USER', 'yein', '123456', '예인', 'female', 'yein@test.com', '1992-05-06', '01011112222'),
(UUID(), 'USER', 'minsu', '123456', '민수', 'male', 'minsu@test.com', '1990-03-10', '01033334444'),
(UUID(), 'NEGOTIATOR', 'lawyerkim', '123456', '김중재', 'male', 'kim@test.com', '1985-07-20', '01055556666');

INSERT INTO user_auth
(id, user_no, username, auth)
VALUES
(UUID(), 1, 'yein', 'ROLE_USER'),
(UUID(), 2, 'minsu', 'ROLE_USER'),
(UUID(), 3, 'lawyerkim', 'ROLE_NEGOTIATOR');

INSERT INTO issue_categories
(id, code, name, description, display_order)
VALUES
(UUID(), 'LOAN', '대여금', '돈을 빌려주고 돌려받지 못한 경우', 1),
(UUID(), 'LEASE', '임대차', '보증금 반환 또는 월세 문제', 2),
(UUID(), 'CONTRACT', '계약', '계약 위반 또는 분쟁', 3),
(UUID(), 'MEMBERSHIP', '회원권 환불', '헬스장, 학원 등 환불 문제', 4);

INSERT INTO issues
(id, user_no, opponent_name, opponent_contact,
conflict_situation, requirements,
issue_code, status)
VALUES
(
UUID(),
1,
'민수',
'01033334444',
'친구에게 300만원을 빌려주었는데 6개월째 갚지 않고 있습니다.',
'300만원 전액을 반환받고 싶습니다.',
'ISSUE-001',
'분석완료'
),
(
UUID(),
2,
'예인',
'01011112222',
'전세 보증금 500만원을 돌려받지 못하고 있습니다.',
'보증금을 반환받고 싶습니다.',
'ISSUE-002',
'상대방대기'
);

INSERT INTO issue_category_mapping
(issue_no, category_no)
VALUES
(1, 1),
(2, 2);

INSERT INTO negotiator_profiles
(id, user_no, introduction, career_years, total_cases, success_cases, success_rate, specialties)
VALUES
(
UUID(),
3,
'10년 경력의 전문 협상가입니다.',
10,
120,
95,
79.17,
JSON_ARRAY('LOAN','CONTRACT')
);

INSERT INTO negotiations
(issue_no, user_no, mediation_proposal, negotiation_proposal, status)
VALUES
(
1,
3,
JSON_ARRAY(
JSON_OBJECT("no",1,"content","3개월 분할 상환"),
JSON_OBJECT("no",2,"content","6개월 분할 상환")
),
JSON_ARRAY(
JSON_OBJECT("no",1,"content","5개월 분할 상환")
),
'대기'
);

INSERT INTO mediation_proposal_logs
(id, category_no, conflict_situation_hash,
conflict_situation, requirements,
mediation_proposals, ai_model)
VALUES
(
UUID(),
1,
SHA2('친구에게 돈을 빌려줌',256),
'친구에게 300만원을 빌려주었는데 돌려받지 못했습니다.',
'300만원 반환 요구',
JSON_ARRAY(
JSON_OBJECT("no",1,"content","3개월 분할 상환"),
JSON_OBJECT("no",2,"content","5개월 분할 상환"),
JSON_OBJECT("no",3,"content","6개월 분할 상환")
),
'gpt-4o'
);

SELECT * FROM users;
SELECT * FROM issues;
SELECT * FROM negotiations;
SELECT * FROM mediation_proposal_logs;