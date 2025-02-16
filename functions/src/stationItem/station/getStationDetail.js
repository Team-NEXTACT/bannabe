const functions = require('firebase-functions');
const {db} = require('../../utils/db');

/**
 * 스테이션 상세정보 조회
 * GET /stations/:stationId
 * Response: RentalStationDetailResponse
 */
exports.getStationDetail = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  try {
    const {stationId} = req.params;

    // 스테이션 정보 조회
    const stationDoc = await db.collection('rentalStations')
      .doc(stationId)
      .get();

    if (!stationDoc.exists) {
      return res.status(404).json({
        success: false,
        message: '존재하지 않는 스테이션입니다.',
      });
    }

    // 해당 스테이션의 대여 가능한 물품 타입 조회
    const itemTypesSnapshot = await db.collection('rentalItemTypes')
      .where('stationId', '==', stationId)
      .get();

    // 대여 가능한 물품 타입 정보 매핑
    const rentalItems = itemTypesSnapshot.docs.map((doc) => ({
      itemTypeId: doc.id,
      name: doc.data().name,
      image: doc.data().imageUrl,
      category: doc.data().category,
      price: doc.data().price,
    }));

    return res.status(200).json({
      success: true,
      data: {
        rentalItems: rentalItems,
      },
    });
  } catch (error) {
    console.error('Get station detail error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
    });
  }
});
