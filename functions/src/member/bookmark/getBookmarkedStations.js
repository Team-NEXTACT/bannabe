const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {authenticateToken} = require('../../middleware/auth');

/**
 * 북마크된 스테이션 조회
 * GET /users/me/stations/bookmark
 * Response: UserBookmarkStationsResponse
 */
exports.getBookmarkedStations = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  await authenticateToken(req, res, async () => {
    try {
      const userId = req.user.email;

      // bookmarks 컬렉션에서 사용자의 북마크 데이터 조회
      const bookmarksSnapshot = await db.collection('bookmarks')
        .where('userId', '==', userId)
        .get();

      // rentalStations와 JOIN하여 스테이션 정보 가져오기
      const bookmarks = await Promise.all(
        bookmarksSnapshot.docs.map(async (doc) => {
          const stationDoc = await db.collection('rentalStations')
            .doc(doc.data().stationId)
            .get();

          if (!stationDoc.exists) {
            return null; // 스테이션이 삭제된 경우 제외
          }

          return {
            name: stationDoc.data().name,
            stationId: stationDoc.id,
          };
        }),
      );

      // null 값 제거 및 이름 기준 오름차순 정렬
      const validBookmarks = bookmarks
        .filter((bookmark) => bookmark !== null)
        .sort((a, b) => a.name.localeCompare(b.name));

      return res.status(200).json({
        success: true,
        data: {
          bookmarks: validBookmarks,
        },
      });
    } catch (error) {
      console.error('Get bookmarked stations error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});
