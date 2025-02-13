const rentalPaymentSchema = {
  type: 'string',
  total_amount: 'number',
  payment_date: 'timestamp',
  order_id: 'string',
  rental_history_id: 'string'
};

module.exports = rentalPaymentSchema; 