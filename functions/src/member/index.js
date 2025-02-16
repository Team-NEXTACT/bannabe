const {register} = require('./auth/register');
const {login} = require('./auth/login');
const {updateProfileImage} = require('./profile/updateProfileImage');
const {updateNickname} = require('./profile/updateNickname');
const {updatePassword} = require('./profile/updatePassword');
const {getActiveRentals} = require('./rental/getActiveRentals');
const {getRentalHistory} = require('./rental/getRentalHistory');
const {getBookmarkedStations} = require('./station/getBookmarkedStations');
const {deleteBookmarkedStation} = require('./station/deleteBookmarkedStation');


exports.register = register;
exports.login = login;
exports.updateProfileImage = updateProfileImage;
exports.updateNickname = updateNickname;
exports.updatePassword = updatePassword;
exports.getActiveRentals = getActiveRentals;
exports.getRentalHistory = getRentalHistory;
exports.getBookmarkedStations = getBookmarkedStations;
exports.deleteBookmarkedStation = deleteBookmarkedStation;
