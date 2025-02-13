const rentalHistorySchema = {
  status: 'string',
  start_time: 'timestamp',
  end_time: 'timestamp',
  return_time: 'timestamp',
  rental_time: 'number',
  user_id: 'string',
  rental_item_id: 'string',
  rental_station_id: 'string',
  return_station_id: 'string'
};

module.exports = rentalHistorySchema; 