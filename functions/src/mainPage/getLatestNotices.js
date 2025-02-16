const functions = require('firebase-functions');
const {db} = require('../utils/db');


// 최신 공지사항 3개 조회
// /notices/latest GET
exports.getLatestNotices = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  try {
    // 최신 공지사항 3개 조회
    const noticesSnapshot = await db.collection('notices')
      .orderBy('createdAt', 'desc') // 최신순 정렬
      .limit(3) // 3개만 가져오기
      .get();

    // 응답 데이터 구성
    const notices = noticesSnapshot.docs.map((doc) => ({
      title: doc.data().title,
      noticeId: doc.id, // 클릭 시 이동을 위한 ID
    }));

    // IndexGetLatestNoticeResponse 형식으로 응답
    return res.status(200).json({
      success: true,
      data: {
        notices: notices,
      },
    });
  } catch (error) {
    console.error('Latest notices error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
    });
  }
});
