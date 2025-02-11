const functions = require('firebase-functions');
const { db } = require('../../utils/db');

exports.getNearbyStations = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({ message: '허용되지 않는 메소드입니다.' });
  }

  try {
    const { latitude, longitude, radius = 1 } = req.query; // radius in kilometers, default 1km

    // Firestore에서 GeoPoint를 사용한 쿼리 구현
    const stationsRef = await db.collection('stations')
      // 여기에 위치 기반 쿼리 로직 구현
      .get();

    const stations = stationsRef.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      // 필요한 정보만 선택하여 반환
      name: doc.data().name,
      address: doc.data().address,
      businessHours: doc.data().businessHours,
      status: doc.data().status
    }));

    res.status(200).json(stations);
  } catch (error) {
    res.status(500).json({ message: '서버 오류가 발생했습니다.' });
  }
});
