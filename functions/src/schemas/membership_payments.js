const membershipPaymentSchema = {
  userId: 'string', // 결제자 이메일
  paymentDate: 'timestamp', // 결제시간
  membershipStartDate: 'timestamp', // 멤버십 시작일
  membershipExpirationDate: 'timestamp', // 멤버십 만료일
  renewalCount: 'number', // 멤버십 갱신 횟수
  totalAmount: 'number', // 결제금액
  orderId: 'string', // PG사 결제 고유번호
};

module.exports = membershipPaymentSchema;
