const functions = require('firebase-functions');
const { db } = require('../../utils/db');

exports.searchStations = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({ message: '허용되지 않는 메소드입니다.' });
  }

  try {
    const { 
      keyword = '', 
      page = 1, 
      limit = 10,
      status,
      sortBy = 'name',
      sortOrder = 'asc'
    } = req.query;

    // 검색어가 없는 경우
    if (!keyword.trim()) {
      return res.status(400).json({ 
        message: '검색어를 입력해주세요.' 
      });
    }

    // 기본 쿼리 설정
    let stationsQuery = db.collection('stations');

    // 검색 조건 설정 (이름 또는 주소에 keyword가 포함된 경우)
    stationsQuery = stationsQuery.where('searchTerms', 'array-contains', keyword.toLowerCase());

    // 스테이션 상태 필터 적용
    if (status) {
      stationsQuery = stationsQuery.where('status', '==', status);
    }

    // 정렬 적용
    const allowedSortFields = ['name', 'address', 'createdAt'];
    if (allowedSortFields.includes(sortBy)) {
      stationsQuery = stationsQuery.orderBy(sortBy, sortOrder);
    }

    // 페이지네이션 적용
    const startAt = (parseInt(page) - 1) * parseInt(limit);
    const stationsRef = await stationsQuery
      .limit(parseInt(limit))
      .offset(startAt)
      .get();

    // 전체 검색 결과 수 조회
    const totalQuery = db.collection('stations')
      .where('searchTerms', 'array-contains', keyword.toLowerCase());
    if (status) {
      totalQuery.where('status', '==', status);
    }
    const totalSnapshot = await totalQuery.get();
    const totalStations = totalSnapshot.size;

    // 검색 결과 데이터 가공
    const stations = await Promise.all(stationsRef.docs.map(async doc => {
      const stationData = doc.data();
      
      // 대여 가능한 물품 수 조회
      const availableItemsRef = await db.collection('rental_items')
        .where('stationId', '==', doc.id)
        .where('status', '==', 'available')
        .get();

      return {
        id: doc.id,
        name: stationData.name,
        address: stationData.address,
        location: stationData.location,
        status: stationData.status,
        businessHours: stationData.businessHours,
        imageUrl: stationData.imageUrl,
        contact: stationData.contact,
        availableItemsCount: availableItemsRef.size,
        // highlight 처리를 위한 검색어 위치 정보
        matches: {
          name: stationData.name.toLowerCase().includes(keyword.toLowerCase()),
          address: stationData.address.toLowerCase().includes(keyword.toLowerCase())
        }
      };
    }));

    // 응답 데이터 구성
    const response = {
      stations,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(totalStations / limit),
        totalStations,
        itemsPerPage: parseInt(limit)
      },
      searchInfo: {
        keyword,
        status,
        sortBy,
        sortOrder
      }
    };

    // 캐시 헤더 설정 (5분)
    res.set('Cache-Control', 'public, max-age=300');
    res.status(200).json(response);

  } catch (error) {
    console.error('Search stations error:', error);
    res.status(500).json({ message: '서버 오류가 발생했습니다.' });
  }
});
