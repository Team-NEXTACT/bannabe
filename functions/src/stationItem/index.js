const { getNearbyStations } = require('./station/getNearbyStations');
const { searchStations } = require('./station/searchStations');
const { getStationDetail } = require('./station/getStationDetail');
const { getStationItems } = require('./station/getStationItems');
const { getRecentStations } = require('./station/getRecentStations');
const { createBookmark } = require('./bookmark/createBookmark');

module.exports = {
  getNearbyStations,    // 주변 스테이션 조회
  searchStations,       // 스테이션 검색
  getStationDetail,     // 스테이션 상세정보 조회
  getStationItems,      // 스테이션 대여물품 상세정보 조회
  getRecentStations,    // 최근 이용 스테이션 조회 (현재 미사용)
  createBookmark,       // 스테이션 북마크 생성
};
