const functions = require('firebase-functions');
const {db} = require('../../utils/db');
const {authenticateToken} = require('../../middleware/auth');
const AWS = require('aws-sdk');

// AWS S3 설정
const s3 = new AWS.S3({
  accessKeyId: functions.config().aws.access_key_id,
  secretAccessKey: functions.config().aws.secret_access_key,
  region: functions.config().aws.region,
});

/**
 * 프로필 이미지 업데이트
 * PATCH /users/me/profile-image
 * Request: UserUpdateProfileImageRequest { imageUrl: string }
 */
exports.updateProfileImage = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'PATCH') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  await authenticateToken(req, res, async () => {
    try {
      const {imageUrl} = req.body;
      const userId = req.user.email;

      // 현재 사용자 정보 조회
      const userRef = await db.collection('users').doc(userId).get();
      const userData = userRef.data();

      // 기존 이미지가 기본 이미지가 아닌 경우 S3에서 삭제
      if (userData.profileImage &&
          userData.profileImage !== 'default_profile_url' &&
          userData.profileImage.includes('amazonaws.com')) {
        const oldImageKey = userData.profileImage.split('/').pop();
        await s3.deleteObject({
          Bucket: functions.config().aws.bucket_name,
          Key: oldImageKey,
        }).promise();
      }

      // 프로필 이미지 URL 업데이트
      await db.collection('users').doc(userId).update({
        profileImage: imageUrl,
      });

      return res.status(200).json({
        success: true,
        message: '프로필 이미지가 업데이트되었습니다.',
      });
    } catch (error) {
      console.error('Update profile image error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});

/**
 * S3 Pre-signed URL 생성
 * GET /users/me/profile-image/presigned-url
 */
exports.getPresignedUrl = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.',
    });
  }

  await authenticateToken(req, res, async () => {
    try {
      const fileExtension = req.query.fileType.split('/')[1];
      const fileName = `${req.user.email}_${Date.now()}.${fileExtension}`;

      const presignedUrl = await s3.getSignedUrlPromise('putObject', {
        Bucket: functions.config().aws.bucket_name,
        Key: `profile-images/${fileName}`,
        Expires: 60 * 5, // URL 유효시간 5분
        ContentType: req.query.fileType,
        ACL: 'public-read',
      });

      return res.status(200).json({
        success: true,
        data: {
          presignedUrl,
          imageUrl: `https://${functions.config().aws.bucket_name}.s3.amazonaws.com/profile-images/${fileName}`,
        },
      });
    } catch (error) {
      console.error('Get presigned URL error:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.',
      });
    }
  });
});
