const functions = require('firebase-functions');
const { db } = require('../../utils/db');
const { authenticateToken } = require('../../middleware/auth');

exports.createBookmark = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: '허용되지 않는 메소드입니다.' });
  }

  await authenticateToken(req, res, async () => {
    try {
      const userId = req.user.uid;
      const { stationId } = req.params;

      // 북마크 중복 체크
      const existingBookmark = await db.collection('bookmark_stations')
        .where('userId', '==', userId)
        .where('stationId', '==', stationId)
        .get();

      if (!existingBookmark.empty) {
        return res.status(409).json({ message: '이미 북마크된 스테이션입니다.' });
      }

      // 북마크 생성
      await db.collection('bookmark_stations').add({
        userId,
        stationId,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });

      res.status(201).json({ message: '북마크가 생성되었습니다.' });
    } catch (error) {
      res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
  });
});
