const userSchema = {
  email: 'string', // 가입 이메일
  password: 'string', // 비밀번호(암호화 필수)
  profileImage: 'string', // 프로필 이미지 URL
  nickname: 'string', // 닉네임(중복 가능)
  membershipStatus: 'boolean', // 멤버십 상태(true: 멤버십 가입, false: 멤버십 미가입)
  membershipInfo: {
    startDate: 'timestamp', // 멤버십 시작일
    expirationDate: 'timestamp', // 멤버십 만료일
    renewalCount: 'number', // 멤버십 갱신 횟수
  },
  createdAt: 'timestamp', // 가입일시
};

module.exports = userSchema;
