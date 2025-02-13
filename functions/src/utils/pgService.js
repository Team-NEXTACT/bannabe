const axios = require('axios');
const { PG_API_ENDPOINT, PG_SECRET_KEY } = require('../config/payment');

/**
 * PG사 결제 승인 요청
 * @param {Object} params
 * @param {string} params.paymentKey - PG사 결제 키
 * @param {string} params.orderId - 주문 ID
 * @param {number} params.amount - 결제 금액
 * @returns {Promise<Object>} 결제 승인 결과
 */
exports.approvePayment = async ({ paymentKey, orderId, amount }) => {
  try {
    // PG사 API 엔드포인트 호출 (예: 토스페이먼츠)
    const response = await axios.post(
      `${PG_API_ENDPOINT}/payments/${paymentKey}`,
      {
        orderId,
        amount
      },
      {
        headers: {
          Authorization: `Basic ${Buffer.from(PG_SECRET_KEY + ':').toString('base64')}`,
          'Content-Type': 'application/json'
        }
      }
    );

    // 결제 승인 성공
    return {
      success: true,
      data: response.data
    };

  } catch (error) {
    console.error('Payment approval error:', error.response?.data || error.message);
    
    // 결제 승인 실패
    return {
      success: false,
      error: error.response?.data || error.message
    };
  }
};

/**
 * PG사 결제 취소 요청
 * @param {string} paymentKey - PG사 결제 키
 * @param {string} cancelReason - 취소 사유
 * @returns {Promise<Object>} 결제 취소 결과
 */
exports.cancelPayment = async (paymentKey, cancelReason) => {
  try {
    const response = await axios.post(
      `${PG_API_ENDPOINT}/payments/${paymentKey}/cancel`,
      {
        cancelReason
      },
      {
        headers: {
          Authorization: `Basic ${Buffer.from(PG_SECRET_KEY + ':').toString('base64')}`,
          'Content-Type': 'application/json'
        }
      }
    );

    return {
      success: true,
      data: response.data
    };

  } catch (error) {
    console.error('Payment cancel error:', error.response?.data || error.message);
    
    return {
      success: false,
      error: error.response?.data || error.message
    };
  }
}; 