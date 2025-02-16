const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {authenticateToken} = require('../../middleware/auth');

/**
 * 닉네임 업데이트
 * PATCH /users/me/nickname
 * Request: UserUpdateNicknameRequest { nickname: string }
 */
exports.updateNickname = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'PATCH') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  await authenticateToken(req, res, async () => {
    try {
      const {nickname} = req.body;
      const userId = req.user.email;

      // 닉네임 유효성 검사
      if (!nickname || nickname.trim() === '') {
        return res.status(400).json({
          success: false,
          message: '닉네임은 필수 입력값입니다.',
        });
      }

      // 닉네임 업데이트
      await db.collection('users').doc(userId).update({
        nickname: nickname.trim(),
      });

      return res.status(200).json({
        success: true,
        message: '닉네임이 업데이트되었습니다.',
      });
    } catch (error) {
      console.error('Update nickname error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});
