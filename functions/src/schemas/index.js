const userSchema = require('./users');
const bookmarkSchema = require('./bookmarks');
const membershipPaymentSchema = require('./membership_payments');
const rentalItemTypeSchema = require('./rental_item_types');
const rentalItemSchema = require('./rental_items');
const rentalStationSchema = require('./rental_stations');
const rentalStationItemSchema = require('./rental_station_items');
const rentalPaymentSchema = require('./rental_payments');
const rentalHistorySchema = require('./rental_history');
const noticeSchema = require('./notices');

module.exports = {
  users: userSchema,
  bookmarks: bookmarkSchema,
  membership_payments: membershipPaymentSchema,
  rental_item_types: rentalItemTypeSchema,
  rental_items: rentalItemSchema,
  rental_stations: rentalStationSchema,
  rental_station_items: rentalStationItemSchema,
  rental_payments: rentalPaymentSchema,
  rental_history: rentalHistorySchema,
  notices: noticeSchema,
};
