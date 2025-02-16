const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {authenticateToken} = require('../../middleware/auth');

/**
 * 활성화된 대여 내역 조회
 * GET /users/me/rentals/active
 * Response: UserGetActiveRentalResponse
 */
exports.getActiveRentals = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  await authenticateToken(req, res, async () => {
    try {
      const userId = req.user.email;

      // rental_history에서 현재 대여중인 항목 조회
      const rentalsSnapshot = await db.collection('rentalHistory')
        .where('userId', '==', userId)
        .where('status', '==', 'Rented')
        .orderBy('startTime', 'desc')
        .get();

      // 대여 정보 매핑
      const rentals = await Promise.all(rentalsSnapshot.docs.map(async (doc) => {
        const rentalData = doc.data();

        // 대여 물품 정보 조회
        const itemDoc = await db.collection('rentalItems')
          .doc(rentalData.itemId)
          .get();
        const itemData = itemDoc.data();

        return {
          name: itemData.name,
          rentalTime: rentalData.rentalTime,
          startTime: rentalData.startTime,
          endTime: rentalData.endTime,
          token: rentalData.token,
        };
      }));

      return res.status(200).json({
        success: true,
        data: {
          rentals: rentals,
        },
      });
    } catch (error) {
      console.error('Get active rentals error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});
