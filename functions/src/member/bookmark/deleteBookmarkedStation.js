// 북마크된 충전소 삭제
// DELETE /api/users/me/stations/bookmark/:stationId
exports.deleteBookmarkedStation = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'DELETE') {
      return res.status(405).json({ message: '허용되지 않는 메소드입니다.' });
    }
  
    await authenticateToken(req, res, async () => {
      try {
        const userId = req.user.uid;
        const stationId = req.params.stationId;
  
        const bookmarkRef = await db.collection('bookmark_stations')
          .where('userId', '==', userId)
          .where('stationId', '==', stationId)
          .get();
  
        if (!bookmarkRef.empty) {
          await bookmarkRef.docs[0].ref.delete();
        }
  
        res.status(200).json({ message: '북마크가 삭제되었습니다.' });
      } catch (error) {
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
      }
    });
  });