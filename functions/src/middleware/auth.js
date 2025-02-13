const admin = require('firebase-admin');

/**
 * Firebase Authentication 토큰 검증 미들웨어
 */
exports.authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: '인증 토큰이 필요합니다.'
      });
    }

    // Bearer 토큰에서 실제 토큰 값 추출
    const idToken = authHeader.split('Bearer ')[1];

    try {
      // Firebase Auth로 토큰 검증
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      
      // 검증된 사용자 정보를 req 객체에 저장
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        // 필요한 경우 추가 claims 정보도 저장
        role: decodedToken.role
      };

      // 다음 미들웨어로 진행
      return next();
      
    } catch (error) {
      console.error('Token verification failed:', error);
      return res.status(403).json({
        success: false,
        message: '유효하지 않은 토큰입니다.'
      });
    }

  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(500).json({
      success: false,
      message: '인증 처리 중 오류가 발생했습니다.'
    });
  }
};