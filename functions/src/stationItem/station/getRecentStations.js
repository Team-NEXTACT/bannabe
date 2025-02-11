const functions = require('firebase-functions');
const { db } = require('../../utils/db');
const { authenticateToken } = require('../../middleware/auth');

exports.getRecentStations = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({ message: '허용되지 않는 메소드입니다.' });
  }

  await authenticateToken(req, res, async () => {
    try {
      const userId = req.user.uid;
      
      // rental_history에서 사용자의 최근 대여 기록 조회
      const rentalHistoryRef = await db.collection('rental_history')
        .where('userId', '==', userId)
        .orderBy('startTime', 'desc')
        .limit(5)  // 최근 5개의 기록만 가져오기
        .get();

      // 중복 제거를 위한 Set 사용
      const stationIds = new Set();
      rentalHistoryRef.docs.forEach(doc => {
        stationIds.add(doc.data().stationId);
      });

      // 스테이션 정보 조회
      const recentStations = [];
      for (const stationId of stationIds) {
        const stationRef = await db.collection('stations').doc(stationId).get();
        
        if (stationRef.exists) {
          recentStations.push({
            id: stationRef.id,
            name: stationRef.data().name,
            address: stationRef.data().address,
            businessHours: stationRef.data().businessHours,
            status: stationRef.data().status,
            location: stationRef.data().location,
            // 필요한 추가 정보들...
          });
        }
      }

      res.status(200).json(recentStations);
    } catch (error) {
      console.error('Recent stations error:', error);
      res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
  });
});
