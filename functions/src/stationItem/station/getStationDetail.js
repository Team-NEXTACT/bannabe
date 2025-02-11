const functions = require('firebase-functions');
const { db } = require('../../utils/db');

// 충전소 상세 정보 조회
exports.getStationDetail = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({ message: '허용되지 않는 메소드입니다.' });
  }

  try {
    const { stationId } = req.params;

    // 스테이션 정보 조회
    const stationRef = await db.collection('stations').doc(stationId).get();

    if (!stationRef.exists) {
      return res.status(404).json({ message: '존재하지 않는 스테이션입니다.' });
    }

    const stationData = stationRef.data();

    // 대여 가능한 물품 조회
    const itemsRef = await db.collection('rental_items')
      .where('stationId', '==', stationId)
      .where('status', '==', 'available')  // 대여 가능한 물품만 조회
      .get();

    const items = itemsRef.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      // 민감한 정보는 제외하고 필요한 정보만 선택
      name: doc.data().name,
      category: doc.data().category,
      status: doc.data().status,
      condition: doc.data().condition,
      imageUrl: doc.data().imageUrl
    }));

    // 응답 데이터 구성
    const response = {
      id: stationRef.id,
      name: stationData.name,
      address: stationData.address,
      location: stationData.location,
      businessHours: stationData.businessHours,
      status: stationData.status,
      contact: stationData.contact,
      description: stationData.description,
      facilities: stationData.facilities,      // 편의시설 정보
      parkingInfo: stationData.parkingInfo,    // 주차 정보
      imageUrl: stationData.imageUrl,          // 스테이션 이미지
      items: items,                            // 대여 가능한 물품 목록
      
      // 운영 정보
      operatingInfo: {
        weekday: stationData.operatingInfo?.weekday,
        weekend: stationData.operatingInfo?.weekend,
        holiday: stationData.operatingInfo?.holiday
      },
      
      // 통계 정보 (옵션)
      statistics: {
        totalItems: items.length,
        availableItems: items.filter(item => item.status === 'available').length,
        // 기타 통계 정보...
      }
    };

    if (req.user) {  // 인증된 사용자인 경우
      const bookmarkRef = await db.collection('bookmark_stations')
        .where('userId', '==', req.user.uid)
        .where('stationId', '==', stationId)
        .get();
      
      response.isBookmarked = !bookmarkRef.empty;
    }

    res.status(200).json(response);
  } catch (error) {
    console.error('Station detail error:', error);
    res.status(500).json({ message: '서버 오류가 발생했습니다.' });
  }
});
