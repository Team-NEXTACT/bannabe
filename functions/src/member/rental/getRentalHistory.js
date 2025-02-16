const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {authenticateToken} = require('../../middleware/auth');

/**
 * 대여 내역 조회
 * GET /users/me/rentals
 * Parameter: size (optional, default: 10)
 * Response: UserRentalHistoryResponse
 */
exports.getRentalHistory = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  await authenticateToken(req, res, async () => {
    try {
      const userId = req.user.email;
      const size = parseInt(req.query.size) || 10; // 기본값 10

      // rental_history 조회 (최신순)
      const rentalsSnapshot = await db.collection('rentalHistory')
        .where('userId', '==', userId)
        .orderBy('startTime', 'desc')
        .limit(size)
        .get();

      // 대여 내역 정보 매핑
      const rentalHistory = await Promise.all(rentalsSnapshot.docs.map(async (doc) => {
        const rentalData = doc.data();

        // 대여 스테이션 정보 조회
        const stationDoc = await db.collection('rentalStations')
          .doc(rentalData.rentalStationId)
          .get();
        const stationData = stationDoc.data();

        // 대여 물품 정보 조회
        const itemDoc = await db.collection('rentalItems')
          .doc(rentalData.rentalItemId)
          .get();
        const itemData = itemDoc.data();

        return {
          name: itemData.name,
          rentalStationName: stationData.name,
          rentalTime: rentalData.rentalTime,
          startTime: rentalData.startTime,
          returnTime: rentalData.returnTime || null, // 반납 전이면 null
        };
      }));

      return res.status(200).json({
        success: true,
        data: {
          rentalHistory: rentalHistory,
        },
      });
    } catch (error) {
      console.error('Get rental history error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});
