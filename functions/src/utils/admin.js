const admin = require('firebase-admin');

// Firebase Admin SDK 초기화
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    // 필요한 경우 다른 설정들 추가
    // databaseURL: 'https://your-project.firebaseio.com'
  });
}

module.exports = admin;
