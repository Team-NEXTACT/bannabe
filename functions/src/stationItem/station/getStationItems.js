const functions = require('firebase-functions');
const {db} = require('../../utils/db');

/**
 * 스테이션 대여물품 상세정보 조회
 * GET /stations/:stationId/items/:itemTypeId
 * Response: RentalItemTypeDetailResponse
 */
exports.getItemTypeDetail = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  try {
    const {stationId, itemTypeId} = req.params;

    // 스테이션 존재 여부 확인
    const stationDoc = await db.collection('rentalStations')
      .doc(stationId)
      .get();

    if (!stationDoc.exists) {
      return res.status(404).json({
        success: false,
        message: '존재하지 않는 스테이션입니다.',
      });
    }

    // 물품 타입 정보 조회
    const itemTypeDoc = await db.collection('rentalItemTypes')
      .doc(itemTypeId)
      .get();

    if (!itemTypeDoc.exists || itemTypeDoc.data().stationId !== stationId) {
      return res.status(404).json({
        success: false,
        message: '존재하지 않는 대여물품입니다.',
      });
    }

    // 재고 수량 계산 (available 상태인 물품 수)
    const availableItemsSnapshot = await db.collection('rentalItems')
      .where('itemTypeId', '==', itemTypeId)
      .where('stationId', '==', stationId)
      .where('status', '==', 'available')
      .get();

    const itemData = itemTypeDoc.data();

    return res.status(200).json({
      success: true,
      data: {
        name: itemData.name,
        image: itemData.imageUrl,
        category: itemData.category,
        description: itemData.description,
        price: itemData.price,
        stock: availableItemsSnapshot.size,
      },
    });
  } catch (error) {
    console.error('Get item type detail error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
    });
  }
});
