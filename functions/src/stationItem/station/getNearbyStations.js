const functions = require('firebase-functions');
const {db} = require('../../utils/db');

/**
 * 주변 스테이션 조회
 * GET /stations
 * Parameter: lat(위도), lng(경도), radius(반경, km 단위, 기본값 1)
 * Response: RentalStationNearByResponse
 */
exports.getNearbyStations = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  try {
    const {lat, lng, radius = 1} = req.query;

    // 파라미터 유효성 검사
    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: '위도와 경도는 필수 입력값입니다.',
      });
    }

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    const radiusInKm = parseFloat(radius);

    // Firestore GeoPoint 범위 계산
    const latRange = radiusInKm / 111.32; // 1도 = 약 111.32km
    const lngRange = radiusInKm / (111.32 * Math.cos(latitude * (Math.PI / 180)));

    // 주변 스테이션 조회
    const stationsSnapshot = await db.collection('rentalStations')
      .where('location.latitude', '>=', latitude - latRange)
      .where('location.latitude', '<=', latitude + latRange)
      .get();

    // 경도 범위는 쿼리로 필터링할 수 없어서 메모리에서 필터링
    const stations = stationsSnapshot.docs
      .map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }))
      .filter((station) => {
        const lngDiff = Math.abs(station.location.longitude - longitude);
        return lngDiff <= lngRange;
      })
      .map((station) => ({
        name: station.name,
        address: station.address,
        latitude: station.location.latitude,
        longitude: station.location.longitude,
        stationStatus: station.status,
        businessTime: station.businessHours,
        grade: station.grade, // 스테이션 등급(광고계약 등)
        stationId: station.id,
      }));

    return res.status(200).json({
      success: true,
      data: {
        stations: stations,
      },
    });
  } catch (error) {
    console.error('Get nearby stations error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
    });
  }
});
