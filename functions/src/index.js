const memberFunctions = require("./member");
const mainPageFunctions = require("./mainPage");
const stationItemFunctions = require("./stationItem");
const rentReturnExtensionFunctions = require("./rentReturnExtension");

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

// StationItem functions
exports.getNearbyStations = stationItemFunctions.getNearbyStations;
exports.searchStations = stationItemFunctions.searchStations;
exports.getStationDetail = stationItemFunctions.getStationDetail;
exports.getStationItems = stationItemFunctions.getStationItems;
exports.getRecentStations = stationItemFunctions.getRecentStations;
exports.createBookmark = stationItemFunctions.createBookmark;

// RentReturnExtension functions will be added here 