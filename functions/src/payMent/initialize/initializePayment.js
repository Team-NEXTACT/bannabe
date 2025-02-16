const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {generateOrderId} = require('../../utils/payment');
const {PG_API_KEY} = require('../../config/payment');
const {authenticateToken} = require('../../middleware/auth');
const admin = require('../../utils/admin');

/**
 * 결제 필요 데이터 요청 (결제 위젯 초기화)
 * POST /payments/initialize
 * Request: PaymentCalculateRequest
 * Response: PaymentInitializeResponse
 */
exports.initializePayment = functions.https.onRequest(async (req, res) => {
  return authenticateToken(req, res, async () => {
    if (req.method !== 'POST') {
      return res.status(405).json({
        success: false,
        message: '허용되지 않는 메소드입니다.',
      });
    }

    try {
      const userId = req.user.email; // 인증된 사용자 ID 사용
      const {rentalItemToken, rentalTime} = req.body;

      // 요청 데이터 검증
      if (!rentalItemToken || !rentalTime) {
        return res.status(400).json({
          success: false,
          message: '필수 파라미터가 누락되었습니다.',
        });
      }

      // 대여 물품 조회
      const rentalItemDoc = await db.collection('rentalItems')
        .doc(rentalItemToken)
        .get();

      if (!rentalItemDoc.exists) {
        return res.status(404).json({
          success: false,
          message: '존재하지 않는 물품입니다.',
        });
      }

      const rentalItemData = rentalItemDoc.data();

      // 대여 가능 상태 확인
      if (rentalItemData.status !== 'available') {
        return res.status(400).json({
          success: false,
          message: '현재 대여가 불가능한 물품입니다.',
        });
      }

      // 물품 타입 정보 조회 (가격, 이름)
      const itemTypeDoc = await db.collection('rentalItemTypes')
        .doc(rentalItemData.itemTypeId)
        .get();

      const itemTypeData = itemTypeDoc.data();

      // 결제 금액 계산 (시간 * 시간당 가격)
      const amount = rentalTime * itemTypeData.price;

      // 주문 ID 생성
      const orderId = generateOrderId(rentalItemToken);

      return res.status(200).json({
        success: true,
        data: {
          apiKey: PG_API_KEY, // PG사 API 키
          orderId: orderId, // 주문 고유 ID
          orderName: itemTypeData.name, // 물품 이름
          currency: 'KRW', // 화폐 단위
          amount: amount, // 계산된 결제 금액
        },
      });
    } catch (error) {
      console.error('Initialize payment error:', error);
      return res.status(500).json({success: false, message: error.message});
    }
  });
});
