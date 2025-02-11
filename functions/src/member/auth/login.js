const functions = require('firebase-functions');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { db } = require('../utils/db');

exports.login = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: '허용되지 않는 메소드입니다.' });
  }

  try {
    const { email, password } = req.body;
    const userRef = await db.collection('users').where('email', '==', email).get();
    
    if (userRef.empty) {
      return res.status(400).json({ message: '이메일 또는 비밀번호가 올바르지 않습니다.' });
    }

    const userData = userRef.docs[0].data();
    const isValidPassword = await bcrypt.compare(password, userData.password);
    
    if (!isValidPassword) {
      return res.status(400).json({ message: '이메일 또는 비밀번호가 올바르지 않습니다.' });
    }

    const token = jwt.sign(
      { uid: userRef.docs[0].id },
      functions.config().jwt.secret,
      { expiresIn: '24h' }
    );

    res.status(200).json({ token });
  } catch (error) {
    res.status(500).json({ message: '서버 오류가 발생했습니다.' });
  }
});
