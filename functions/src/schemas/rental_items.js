const rentalItemSchema = {
  status: 'string', // 대여 상태(rented, returned, overdue 등)
  price: 'number', // 시간당 금액
  token: 'string', // 토큰
  rentalItemTypeId: 'string', // 대여 물품 타입 ID
  createdAt: 'timestamp', // 생성일시
  currentStationId: 'string', // 현재 스테이션 ID
};

module.exports = rentalItemSchema;
