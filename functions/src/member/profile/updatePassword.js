const functions = require('firebase-functions');
const bcrypt = require('bcrypt');
const {db} = require('../../utils/db');
const {authenticateToken} = require('../../middleware/auth');

/**
 * 비밀번호 업데이트
 * PUT /users/me/password
 * Request: UserUpdatePasswordRequest {
 *   currentPassword: string,
 *   newPassword: string,
 *   newPasswordConfirm: string
 * }
 */
exports.updatePassword = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'PUT') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  await authenticateToken(req, res, async () => {
    try {
      const {currentPassword, newPassword, newPasswordConfirm} = req.body;
      const userId = req.user.email;

      // 필수 입력값 검증
      if (!currentPassword || !newPassword || !newPasswordConfirm) {
        return res.status(400).json({
          success: false,
          message: '모든 필드를 입력해주세요.',
        });
      }

      // 새 비밀번호 일치 여부 검증
      if (newPassword !== newPasswordConfirm) {
        return res.status(400).json({
          success: false,
          message: '새 비밀번호가 일치하지 않습니다.',
        });
      }

      // 현재 사용자 정보 조회
      const userDoc = await db.collection('users').doc(userId).get();
      const userData = userDoc.data();

      // 현재 비밀번호 검증
      const isValidPassword = await bcrypt.compare(currentPassword, userData.password);
      if (!isValidPassword) {
        return res.status(400).json({
          success: false,
          message: '현재 비밀번호가 올바르지 않습니다.',
        });
      }

      // 새 비밀번호 해시화 및 업데이트
      const hashedNewPassword = await bcrypt.hash(newPassword, 10);
      await db.collection('users').doc(userId).update({
        password: hashedNewPassword,
      });

      return res.status(200).json({
        success: true,
        message: '비밀번호가 성공적으로 변경되었습니다.',
      });
    } catch (error) {
      console.error('Update password error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});
