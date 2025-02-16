const functions = require('firebase-functions');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const {db} = require('../../utils/db');

/**
 * 로그인 API
 * POST /auth/login
 * Request: UserLoginRequest { email: string, password: string }
 */
exports.login = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  try {
    const {email, password} = req.body;

    // 필수 입력값 검증
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: '이메일과 비밀번호는 필수 입력값입니다.',
      });
    }

    // 이메일로 사용자 조회
    const userRef = await db.collection('users').where('email', '==', email).get();

    if (userRef.empty) {
      return res.status(400).json({
        success: false,
        message: '이메일 또는 비밀번호가 올바르지 않습니다.',
      });
    }

    const userData = userRef.docs[0].data();

    // 비밀번호 검증
    const isValidPassword = await bcrypt.compare(password, userData.password);
    if (!isValidPassword) {
      return res.status(400).json({
        success: false,
        message: '이메일 또는 비밀번호가 올바르지 않습니다.',
      });
    }

    // JWT 토큰 생성
    const token = jwt.sign(
      {
        uid: userRef.docs[0].id,
        email: userData.email,
      },
      functions.config().jwt.secret,
      {expiresIn: '24h'},
    );

    return res.status(200).json({
      success: true,
      data: {token},
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
    });
  }
});
