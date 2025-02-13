const functions = require('firebase-functions');
const { db } = require('../../utils/db');
const { generateOrderId } = require('../../utils/payment');
const { PG_API_KEY } = require('../../config/payment');

/**
 * 연체 결제 필요 데이터 요청 (연체 결제 위젯 초기화)
 * POST /payments/initialize-overdue
 * Request: PaymentOverdueCalculateRequest
 * Response: PaymentOverdueInitializeResponse
 */
exports.initializeOverduePayment = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.'
    });
  }

  try {
    const { rentalItemToken } = req.body;

    // 요청 데이터 검증
    if (!rentalItemToken) {
      return res.status(400).json({
        success: false,
        message: '필수 파라미터가 누락되었습니다.'
      });
    }

    // 대여 이력 조회 (status가 'OverDue'인 최신 기록)
    const rentalHistorySnapshot = await db.collection('rental_history')
      .where('rentalItemId', '==', rentalItemToken)
      .where('status', '==', 'OverDue')
      .orderBy('startTime', 'desc')
      .limit(1)
      .get();

    if (rentalHistorySnapshot.empty) {
      return res.status(400).json({
        success: false,
        message: '연체된 대여 기록이 없습니다.'
      });
    }

    const rentalHistory = rentalHistorySnapshot.docs[0].data();
    const currentTime = new Date();
    const endTime = rentalHistory.endTime.toDate();
    
    // 연체 시간 계산 (밀리초 -> 시간)
    const overdueTimeMs = currentTime.getTime() - endTime.getTime();
    const overdueHours = Math.ceil(overdueTimeMs / (1000 * 60 * 60));

    // 물품 타입 정보 조회 (가격, 이름)
    const itemTypeDoc = await db.collection('rental_item_types')
      .doc(rentalHistory.itemTypeId)
      .get();

    const itemTypeData = itemTypeDoc.data();
    
    // 연체 금액 계산 (연체 시간 * 시간당 가격)
    const amount = overdueHours * itemTypeData.price;

    // 주문 ID 생성
    const orderId = generateOrderId(rentalItemToken);

    return res.status(200).json({
      success: true,
      data: {
        apiKey: PG_API_KEY,                    // PG사 API 키
        orderId: orderId,                      // 주문 고유 ID
        orderName: `${itemTypeData.name} 연체료`, // 물품 이름 + 연체료
        expectedEndTime: rentalHistory.endTime, // 원래 반납 예정 시간
        overdueTime: `${overdueHours}시간`,     // 연체 시간
        currency: 'KRW',                       // 화폐 단위
        amount: amount                         // 계산된 연체 금액
      }
    });

  } catch (error) {
    console.error('Initialize overdue payment error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});
