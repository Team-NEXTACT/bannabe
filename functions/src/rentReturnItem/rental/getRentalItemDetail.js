const functions = require('firebase-functions');
const {db} = require('../../utils/db');

/**
 * 대여물품 데이터 조회
 * GET /rentals/:rentalItemToken
 * Response: RentalItemDetailResponse
 */
exports.getRentalItemDetail = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  try {
    const {rentalItemToken} = req.params;

    // 대여 물품 조회
    const rentalItemDoc = await db.collection('rentalItems')
      .doc(rentalItemToken)
      .get();

    if (!rentalItemDoc.exists) {
      return res.status(404).json({
        success: false,
        message: '존재하지 않는 물품입니다.',
      });
    }

    const rentalItemData = rentalItemDoc.data();

    // 대여 가능 상태 확인
    if (rentalItemData.status !== 'available') {
      return res.status(400).json({
        success: false,
        message: '현재 대여가 불가능한 물품입니다.',
      });
    }

    // 스테이션 정보 조회
    const stationDoc = await db.collection('rentalStations')
      .doc(rentalItemData.stationId)
      .get();

    // 물품 타입 정보 조회
    const itemTypeDoc = await db.collection('rentalItemTypes')
      .doc(rentalItemData.itemTypeId)
      .get();

    const itemTypeData = itemTypeDoc.data();

    return res.status(200).json({
      success: true,
      data: {
        name: itemTypeData.name,
        description: itemTypeData.description,
        image: itemTypeData.imageUrl,
        price: itemTypeData.price,
        currentStationName: stationDoc.data().name,
      },
    });
  } catch (error) {
    console.error('Get rental item detail error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
    });
  }
});
