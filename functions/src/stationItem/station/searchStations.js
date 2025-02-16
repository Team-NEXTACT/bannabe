const functions = require('firebase-functions');
const {db} = require('../../utils/db');

/**
 * 스테이션 검색
 * GET /stations/search?keyword=
 * Response: RentalStationSearchResponse
 */
exports.searchStations = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  try {
    const {keyword = ''} = req.query;

    // 검색어가 없는 경우
    if (!keyword.trim()) {
      return res.status(400).json({
        success: false,
        message: '검색어를 입력해주세요.',
      });
    }

    // stations 컬렉션에서 전체 데이터 조회
    const stationsSnapshot = await db.collection('rentalStations')
      .orderBy('name')
      .get();

    // 검색어를 포함하는 스테이션 필터링
    const stations = stationsSnapshot.docs
      .filter((doc) => {
        const data = doc.data();
        const searchKeyword = keyword.toLowerCase();
        return data.name.toLowerCase().includes(searchKeyword) ||
               data.address.toLowerCase().includes(searchKeyword);
      })
      .map((doc) => ({
        name: doc.data().name,
        address: doc.data().address,
        stationId: doc.id,
      }))
      .slice(0, 20); // 상위 20개만 반환

    return res.status(200).json({
      success: true,
      data: {
        stations: stations,
      },
    });
  } catch (error) {
    console.error('Search stations error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
    });
  }
});
