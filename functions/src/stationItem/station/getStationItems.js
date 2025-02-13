const functions = require('firebase-functions');
const { db } = require('../../utils/db');

// 충전소 아이템 조회
exports.getStationItems = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.'
    });
  }

  try {
    const { stationId, itemTypeId } = req.params;

    // 스테이션 존재 여부 확인
    const stationDoc = await db.collection('stations')
      .doc(stationId)
      .get();

    if (!stationDoc.exists) {
      return res.status(404).json({
        success: false,
        message: '존재하지 않는 스테이션입니다.'
      });
    }

    // itemTypeId가 있는 경우 상세 정보 조회
    if (itemTypeId) {
      // 물품 타입 정보 조회
      const itemTypeDoc = await db.collection('item_types')
        .doc(itemTypeId)
        .get();

      if (!itemTypeDoc.exists || itemTypeDoc.data().stationId !== stationId) {
        return res.status(404).json({
          success: false,
          message: '존재하지 않는 대여물품입니다.'
        });
      }

      // 재고 수량 계산 (available 상태인 물품 수)
      const availableItemsSnapshot = await db.collection('rental_items')
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
          stock: availableItemsSnapshot.size
        }
      });
    }

    // itemTypeId가 없는 경우 기존의 스테이션 아이템 목록 조회 로직
    const { category, status, page = 1, limit = 10 } = req.query;

    // 기본 쿼리 설정
    let itemsQuery = db.collection('rental_items')
      .where('stationId', '==', stationId);

    // 카테고리 필터 적용
    if (category) {
      itemsQuery = itemsQuery.where('category', '==', category);
    }

    // 상태 필터 적용
    if (status) {
      itemsQuery = itemsQuery.where('status', '==', status);
    }

    // 정렬 적용 (최신순)
    itemsQuery = itemsQuery.orderBy('createdAt', 'desc');

    // 페이지네이션 적용
    const startAt = (page - 1) * limit;
    const itemsRef = await itemsQuery
      .limit(parseInt(limit))
      .offset(startAt)
      .get();

    // 전체 아이템 수 조회 (페이지네이션 정보용)
    const totalQuery = db.collection('rental_items')
      .where('stationId', '==', stationId);
    const totalSnapshot = await totalQuery.get();
    const totalItems = totalSnapshot.size;

    // 아이템 데이터 가공
    const items = itemsRef.docs.map(doc => ({
      id: doc.id,
      name: doc.data().name,
      category: doc.data().category,
      status: doc.data().status,
      condition: doc.data().condition,
      imageUrl: doc.data().imageUrl,
      description: doc.data().description,
      rentalPrice: doc.data().rentalPrice,
      deposit: doc.data().deposit,
      manufacturer: doc.data().manufacturer,
      modelNumber: doc.data().modelNumber,
      purchaseDate: doc.data().purchaseDate,
      lastMaintenanceDate: doc.data().lastMaintenanceDate,
      // 민감한 정보는 제외
    }));

    // 카테고리별 통계
    const categoryStats = {};
    if (!category) {  // 카테고리 필터가 없을 때만 통계 계산
      const allItems = await db.collection('rental_items')
        .where('stationId', '==', stationId)
        .get();
        
      allItems.docs.forEach(doc => {
        const itemCategory = doc.data().category;
        if (!categoryStats[itemCategory]) {
          categoryStats[itemCategory] = {
            total: 0,
            available: 0
          };
        }
        categoryStats[itemCategory].total++;
        if (doc.data().status === 'available') {
          categoryStats[itemCategory].available++;
        }
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        items,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalItems / limit),
          totalItems,
          itemsPerPage: parseInt(limit)
        },
        categoryStats: Object.keys(categoryStats).length > 0 ? categoryStats : undefined
      }
    });
  } catch (error) {
    console.error('Get station items error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});
