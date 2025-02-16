const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {authenticateToken} = require('../../middleware/auth');

const db = admin.firestore();

// 대여 반납 처리
exports.returnRentalItem = functions.https.onRequest(async (req, res) => {
  await authenticateToken(req, res, async () => {
    try {
      const {rentalItemId} = req.params;
      const {stationId} = req.body;

      // 현재 대여 기록 조회
      const rentalHistoryRef = await db.collection('rentalHistory')
        .where('rentalItemId', '==', rentalItemId)
        .where('userId', '==', req.user.email)
        .where('status', 'in', ['Rented', 'OverDue_Paid'])
        .get();

      if (rentalHistoryRef.empty) {
        return res.status(404).json({
          error: '대여 기록을 찾을 수 없습니다.',
        });
      }

      const rentalHistory = rentalHistoryRef.docs[0];
      const currentStatus = rentalHistory.data().status;

      // 반납 가능 상태 확인
      if (currentStatus !== 'Rented' && currentStatus !== 'OverDue_Paid') {
        return res.status(400).json({
          error: '현재 상태에서는 반납이 불가능합니다.',
        });
      }

      const now = admin.firestore.Timestamp.now();
      const startTime = rentalHistory.data().startTime;
      const usedTime = now.seconds - startTime.seconds; // 실제 사용 시간(초 단위)

      // 트랜잭션으로 반납 처리
      await db.runTransaction(async (transaction) => {
        // 대여 기록 업데이트
        transaction.update(rentalHistory.ref, {
          status: 'Returned',
          returnTime: now,
          rentalTime: usedTime,
        });

        // 대여 물품 상태 업데이트
        const rentalItemRef = db.collection('rentalItems').doc(rentalItemId);
        transaction.update(rentalItemRef, {
          status: 'Available',
          currentStationId: stationId,
        });
      });

      res.status(200).json({
        message: '반납이 완료되었습니다.',
        stationId: stationId,
      });
    } catch (error) {
      console.error('반납 처리 중 오류 발생:', error);
      res.status(500).json({
        error: '반납 처리 중 오류가 발생했습니다.',
      });
    }
  });
});
