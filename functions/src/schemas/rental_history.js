const rentalHistorySchema = {
  status: 'string', // 대여 상태(rented, returned, overdue 등)
  startTime: 'timestamp', // 대여 시작 시간
  endTime: 'timestamp', // 대여 종료 시간
  returnTime: 'timestamp', // 반납 시간
  rentalTime: 'number', // 대여 사용 시간
  userId: 'string', // 대여자 ID
  rentalItemId: 'string', // 대여물품 ID
  rentalStationId: 'string', // 대여 스테이션 ID
  returnStationId: 'string', // 반납 스테이션 ID
};

module.exports = rentalHistorySchema;
