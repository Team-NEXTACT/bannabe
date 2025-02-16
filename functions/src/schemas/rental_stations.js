const rentalStationSchema = {
  name: 'string', // 스테이션 이름
  address: 'string', // 주소
  latitude: 'number', // 위도
  longitude: 'number', // 경도
  businessTime: 'string', // 영업시간
  stationsStatus: 'string', // 스테이션 상태(Open, Closed, Maintenance 등)
  grade: 'string', // 스테이션 등급
};

module.exports = rentalStationSchema;
