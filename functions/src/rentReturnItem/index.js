/**
 * 대여/반납 관련 기능 모음
 *
 * 대여 관련:
 * - getRentalItemDetail: QR 스캔 후 대여물품 상세 정보 조회 (/rentals/:rentalItemToken)
 *   - 대여 가능 여부 확인
 *   - 물품 정보(이름, 이미지, 가격 등) 제공
 *
 * 반납 관련:
 * - getReturnItemDetail: QR 스캔 후 반납물품 상세 정보 조회 (/returns/:rentalItemToken)
 *   - 대여 이력 조회 및 연체 상태 확인
 *   - 대여자 정보, 대여 시간, 반납 예정 시간 등 제공
 */

const {getRentalItemDetail} = require('./rental/getRentalItemDetail');
const {getReturnItemDetail} = require('./return/getReturnItemDetail');

// 대여 관련 기능
exports.getRentalItemDetail = getRentalItemDetail; // 대여물품 데이터 조회

// 반납 관련 기능
exports.getReturnItemDetail = getReturnItemDetail; // 반납물품 데이터 조회
