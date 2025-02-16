const functions = require('firebase-functions');
const bcrypt = require('bcrypt');
const {db} = require('../../utils/db');
const admin = require('firebase-admin');

/**
 * 회원가입 API
 * POST /auth/register
 * Request: UserRegisterRequest { email: string, password: string }
 */
exports.register = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  try {
    const {email, password} = req.body;

    // 이메일 형식 검증
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: '이메일과 비밀번호는 필수 입력값입니다.',
      });
    }

    // 이메일 중복 체크
    const userRef = await db.collection('users').where('email', '==', email).get();
    if (!userRef.empty) {
      return res.status(409).json({
        success: false,
        message: '이미 존재하는 이메일입니다.',
      });
    }

    // 비밀번호 해시화
    const hashedPassword = await bcrypt.hash(password, 10);

    // 랜덤 닉네임 생성
    const randomNickname = `User${Math.random().toString(36).substr(2, 9)}`;

    // 사용자 데이터 저장
    await db.collection('users').add({
      email,
      password: hashedPassword,
      nickname: randomNickname,
      profileImage: 'default_profile_url',
      membershipStatus: false,
      membershipInfo: {},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return res.status(201).json({
      success: true,
      message: '회원가입이 완료되었습니다.',
    });
  } catch (error) {
    console.error('Register error:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
    });
  }
});
