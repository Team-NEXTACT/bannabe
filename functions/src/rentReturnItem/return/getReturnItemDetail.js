const functions = require('firebase-functions');
const {db} = require('../../utils/db');

/**
 * 반납 물품 데이터 조회
 * GET /returns/:rentalItemToken
 * Response: ReturnItemDetailResponse
 */
exports.getReturnItemDetail = functions.https.onRequest(async (req, res) => {
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

    // 대여 이력 조회 (status가 'Rented'인 최신 기록)
    const rentalHistorySnapshot = await db.collection('rentalHistory')
      .where('rentalItemId', '==', rentalItemToken)
      .where('status', '==', 'Rented')
      .orderBy('startTime', 'desc')
      .limit(1)
      .get();

    if (rentalHistorySnapshot.empty) {
      return res.status(400).json({
        success: false,
        message: '현재 대여 중인 물품이 아닙니다.',
      });
    }

    const rentalHistory = rentalHistorySnapshot.docs[0].data();
    const currentTime = new Date();
    const endTime = rentalHistory.endTime.toDate();

    // 연체 상태 확인 및 업데이트
    let status = rentalHistory.status;
    if (currentTime > endTime && status === 'Rented') {
      status = 'OverDue';
      // rental_history 상태 업데이트
      await rentalHistorySnapshot.docs[0].ref.update({
        status: 'OverDue',
      });
    }

    // 사용자 정보 조회
    const userDoc = await db.collection('users')
      .doc(rentalHistory.userId)
      .get();

    // 물품 타입 정보 조회
    const itemTypeDoc = await db.collection('rentalItemTypes')
      .doc(rentalItemData.itemTypeId)
      .get();

    // 스테이션 정보 조회
    const stationDoc = await db.collection('rentalStations')
      .doc(rentalItemData.stationId)
      .get();

    return res.status(200).json({
      success: true,
      data: {
        rentalItem: {
          name: itemTypeDoc.data().name,
        },
        rentalUser: {
          nickname: userDoc.data().nickname,
        },
        rentalHistory: {
          status: status,
          startTime: rentalHistory.startTime.toISOString(),
          endTime: rentalHistory.endTime.toISOString(),
          rentalTime: rentalHistory.rentalTime,
        },
        rentalStation: {
          rentalStationName: rentalHistory.rentalStationName,
          currentStationName: stationDoc.data().name,
        },
      },
    });
  } catch (error) {
    console.error('Get return item detail error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
    });
  }
});
