const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {authenticateToken} = require('../../middleware/auth');

/**
 * 스테이션 북마크 생성
 * POST /stations/:stationId/bookmark
 */
exports.createBookmark = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  await authenticateToken(req, res, async () => {
    try {
      const userId = req.user.email;
      const {stationId} = req.params;

      // 스테이션 존재 여부 및 이름 확인
      const stationDoc = await db.collection('rentalStations')
        .doc(stationId)
        .get();

      if (!stationDoc.exists) {
        return res.status(404).json({
          success: false,
          message: '존재하지 않는 스테이션입니다.',
        });
      }

      const stationName = stationDoc.data().name;

      // 북마크 중복 체크
      const existingBookmark = await db.collection('bookmarks')
        .where('stationId', '==', stationId)
        .where('userId', '==', userId)
        .get();

      if (!existingBookmark.empty) {
        return res.status(409).json({
          success: false,
          message: '이미 북마크된 스테이션입니다.',
        });
      }

      // 북마크 생성
      await db.collection('bookmarks').add({
        stationId: stationId,
        stationName: stationName,
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
        userId: userId, // 사용자 식별을 위한 필드
      });

      return res.status(201).json({
        success: true,
        message: '북마크가 생성되었습니다.',
      });
    } catch (error) {
      console.error('Create bookmark error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});
