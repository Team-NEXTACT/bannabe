const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {generateOrderId} = require('../../utils/payment');
const {PG_API_KEY} = require('../../config/payment');
const {authenticateToken} = require('../../middleware/auth');
const admin = require('../../utils/admin');

/**
 * 연체 결제 필요 데이터 요청 (연체 결제 위젯 초기화)
 * POST /payments/initialize-overdue
 * Request: PaymentOverdueCalculateRequest
 * Response: PaymentOverdueInitializeResponse
 */
exports.initializeOverduePayment = functions.https.onRequest(async (req, res) => {
  return authenticateToken(req, res, async () => {
    try {
      const userId = req.user.email;
      const {rentalHistoryToken, overdueTime} = req.body;

      // 요청 데이터 검증
      if (!rentalHistoryToken || !overdueTime) {
        return res.status(400).json({
          success: false,
          message: '필수 파라미터가 누락되었습니다.',
        });
      }

      // 대여 기록 조회
      const rentalHistoryDoc = await db.collection('rentalHistory')
        .doc(rentalHistoryToken)
        .get();

      if (!rentalHistoryDoc.exists) {
        return res.status(404).json({
          success: false,
          message: '대여 기록을 찾을 수 없습니다.',
        });
      }

      const rentalHistory = rentalHistoryDoc.data();

      // 연체 상태 확인
      if (rentalHistory.status !== 'OverDue') {
        return res.status(400).json({
          success: false,
          message: '연체 상태의 대여 기록만 결제가 가능합니다.',
        });
      }

      // 물품 타입 정보 조회
      const itemTypeDoc = await db.collection('rentalItemTypes')
        .doc(rentalHistory.itemTypeId)
        .get();

      const itemTypeData = itemTypeDoc.data();

      // 연체 금액 계산 (연체 시간 * 시간당 가격)
      const amount = overdueTime * itemTypeData.price;

      // 주문 ID 생성
      const orderId = generateOrderId(rentalHistoryToken);

      return res.status(200).json({
        success: true,
        data: {
          apiKey: PG_API_KEY, // PG사 API 키
          orderId: orderId, // 주문 고유 ID
          orderName: `${itemTypeData.name} 연체`, // 물품 이름 + 연체
          overdueTime: `${overdueTime}시간`, // 연체 시간
          currency: 'KRW', // 화폐 단위
          amount: amount, // 계산된 연체 금액
        },
      });
    } catch (error) {
      console.error('Initialize overdue payment error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});
