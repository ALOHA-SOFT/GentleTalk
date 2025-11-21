// User types enum
enum UserType {
  user('이용자'),
  negotiator('협상가'),
  admin('관리자');

  final String label;
  const UserType(this.label);
}

// Gender enum
enum Gender {
  male('남성'),
  female('여성');

  final String label;
  const Gender(this.label);
}
