const { PubSub } = require('@google-cloud/pubsub');
const pubsub = new PubSub();

/**
 * 이벤트 발행 함수
 * @param {string} eventName - 이벤트 이름 (예: 'RentalHistorySave')
 * @param {Object} data - 이벤트 데이터
 * @param {Object} options - 이벤트 옵션 (재시도 횟수, 딜레이 등)
 */
exports.publishEvent = async (eventName, data, options = {}) => {
  try {
    // 토픽 이름 생성 (예: 'rental-history-save')
    const topicName = eventName.toLowerCase().replace(/_/g, '-');
    const topic = pubsub.topic(topicName);

    // 메시지 데이터를 Buffer로 변환
    const messageBuffer = Buffer.from(JSON.stringify(data));

    // 메시지 속성 설정
    const attributes = {
      eventName,
      retryCount: options.retryCount?.toString() || '3',
      retryDelay: options.retryDelay?.toString() || '1000'
    };

    // 이벤트 발행
    const messageId = await topic.publish(messageBuffer, attributes);
    console.log(`Event published: ${eventName}, MessageId: ${messageId}`);

    return {
      success: true,
      messageId
    };

  } catch (error) {
    console.error(`Failed to publish event ${eventName}:`, error);
    throw error;
  }
}; 