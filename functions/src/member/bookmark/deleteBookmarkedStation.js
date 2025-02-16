const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {authenticateToken} = require('../../middleware/auth');

/**
 * 북마크된 스테이션 삭제
 * DELETE /users/me/stations/bookmark/:stationId
 */
exports.deleteBookmarkedStation = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'DELETE') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  await authenticateToken(req, res, async () => {
    try {
      const userId = req.user.email; // email을 userId로 사용
      const stationId = req.params.stationId; // URL path에서 stationId 추출

      // bookmarks에서 해당 북마크 찾기
      const bookmarkRef = await db.collection('bookmarks')
        .where('userId', '==', userId)
        .where('stationId', '==', stationId)
        .get();

      // 북마크가 존재하면 삭제
      if (!bookmarkRef.empty) {
        await bookmarkRef.docs[0].ref.delete();
      }

      return res.status(200).json({
        success: true,
        message: '북마크가 삭제되었습니다.',
      });
    } catch (error) {
      console.error('Delete bookmarked station error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});
