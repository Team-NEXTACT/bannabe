const rentalPaymentSchema = {
  type: 'string', // 결제타입(대여, 연장, 연체)
  method: 'string', // 결제수단(신용카드, 현금)
  totalAmount: 'number', // 결제금액
  paymentDate: 'timestamp', // 결제시간
  orderId: 'string', // 주문 식별 고유 번호
  paymentKey: 'string', // PG사 결제 고유키키
  rentalHistoryId: 'string', // 대여이력ID
};

module.exports = rentalPaymentSchema;
