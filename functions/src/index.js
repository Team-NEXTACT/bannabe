const memberFunctions = require('./member');
const mainPageFunctions = require('./mainPage');
const stationItemFunctions = require('./stationItem');
const rentReturnExtensionFunctions = require('./rentReturnExtension');
const paymentFunctions = require('./payMent');

// Member functions
exports.register = memberFunctions.register;
exports.login = memberFunctions.login;
exports.updateProfileImage = memberFunctions.updateProfileImage;
exports.updateNickname = memberFunctions.updateNickname;
exports.updatePassword = memberFunctions.updatePassword;
exports.getActiveRentals = memberFunctions.getActiveRentals;
exports.getRentalHistory = memberFunctions.getRentalHistory;
exports.getBookmarkedStations = memberFunctions.getBookmarkedStations;
exports.deleteBookmarkedStation = memberFunctions.deleteBookmarkedStation;

// MainPage functions will be added here
exports.getLatestNotices = mainPageFunctions.getLatestNotices;


// StationItem functions
exports.getNearbyStations = stationItemFunctions.getNearbyStations;
exports.searchStations = stationItemFunctions.searchStations;
exports.getStationDetail = stationItemFunctions.getStationDetail;
exports.getStationItems = stationItemFunctions.getStationItems;
exports.createBookmark = stationItemFunctions.createBookmark;

// RentReturnExtension functions will be added here
exports.getRentalItemDetail = rentReturnExtensionFunctions.getRentalItemDetail;
exports.getReturnItemDetail = rentReturnExtensionFunctions.getReturnItemDetail;

// Payment functions will be added here
exports.initializePayment = paymentFunctions.initializePayment;
exports.initializeOverduePayment = paymentFunctions.initializeOverduePayment;
exports.initializeExtendPayment = paymentFunctions.initializeExtendPayment;
exports.approveRentalPayment = paymentFunctions.approveRentalPayment;
exports.approveRenewalPayment = paymentFunctions.approveRenewalPayment;
exports.approveOverduePayment = paymentFunctions.approveOverduePayment;

