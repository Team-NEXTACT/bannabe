const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {approvePayment} = require('../../utils/pgService');
const {publishEvent} = require('../../utils/eventPublisher');
const {authenticateToken} = require('../../middleware/auth');
const admin = require('../../utils/admin');

/**
 * 대여 결제 승인 및 저장
 * POST /payments/approve-rental
 * Request: PaymentRentalConfirmRequest
 */
exports.approveRentalPayment = functions.https.onRequest(async (req, res) => {
  return authenticateToken(req, res, async () => {
    if (req.method !== 'POST') {
      return res.status(405).json({
        success: false,
        message: '허용되지 않는 메소드입니다.',
      });
    }

    // 인증된 사용자 ID 사용
    const userId = req.user.email;

    try {
      const result = await db.runTransaction(async (t) => {
        const {
          payments: {orderId, paymentKey, amount},
          rentals: {rentalItemToken, rentalTime},
        } = req.body;

        // 요청 데이터 검증
        if (!orderId || !paymentKey || !amount || !rentalItemToken || !rentalTime) {
          return res.status(400).json({
            success: false,
            message: '필수 파라미터가 누락되었습니다.',
          });
        }

        // 대여 물품 조회 및 상태 확인
        const rentalItemRef = db.collection('rentalItems').doc(rentalItemToken);
        const rentalItemDoc = await t.get(rentalItemRef);

        if (!rentalItemDoc.exists) {
          throw new Error('존재하지 않는 물품입니다.');
        }

        if (rentalItemDoc.data().status !== 'available') {
          throw new Error('현재 대여가 불가능한 물품입니다.');
        }

        // PG사 결제 승인 요청
        const paymentResult = await approvePayment({
          paymentKey,
          orderId,
          amount,
        });

        if (!paymentResult.success) {
          throw new Error('결제 승인에 실패했습니다.');
        }

        // 대여 이력 저장 이벤트 발행
        const rentalHistoryData = {
          userId: userId,
          status: 'Rented',
          startTime: admin.firestore.FieldValue.serverTimestamp(),
          endTime: new Date(Date.now() + (rentalTime * 60 * 60 * 1000)),
          returnTime: null,
          rentalTime: rentalTime,
          rentalItemId: rentalItemToken,
          rentalStationId: rentalItemDoc.data().stationId,
          returnStationId: null,
        };

        await publishEvent('RentalHistorySave', rentalHistoryData, {
          retryCount: 3,
          retryDelay: 1000,
        });

        // 결제 내역 저장
        const paymentRef = db.collection('rentalPayments').doc();
        t.set(paymentRef, {
          type: 'credit_card',
          totalAmount: parseInt(amount),
          paymentDate: admin.firestore.FieldValue.serverTimestamp(),
          orderId: orderId,
          rentalHistoryId: rentalHistoryData.rentalItemId,
        });

        // 물품 상태 업데이트
        t.update(rentalItemRef, {
          status: 'rented',
        });

        return {
          paymentId: paymentRef.id,
          rentalHistoryData,
        };
      });

      return res.status(200).json({
        success: true,
        data: {
          paymentId: result.paymentId,
          startTime: result.rentalHistoryData.startTime,
          endTime: result.rentalHistoryData.endTime,
          message: '결제 및 대여가 완료되었습니다.',
        },
      });
    } catch (error) {
      console.error('Approve rental payment error:', error);
      return res.status(500).json({
        success: false,
        message: error.message || '서버 오류가 발생했습니다.',
      });
    }
  });
});
