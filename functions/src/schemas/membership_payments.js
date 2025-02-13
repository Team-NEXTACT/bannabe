const membershipPaymentSchema = {
  user_id: 'string',
  payment_date: 'timestamp',
  membership_start_date: 'timestamp',
  membership_expiration_date: 'timestamp',
  renewal_count: 'number',
  total_amount: 'number',
  order_id: 'string'
};

module.exports = membershipPaymentSchema; 