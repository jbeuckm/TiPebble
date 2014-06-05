// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
win.add(label);
win.open();

// TODO: write your module tests here
var pebble = require('org.beuckman.pebble');
Ti.API.info("module is => " + pebble);

var guid = Ti.Platform.createUUID();
pebble.setAppUUID(guid);


pebble.addEventListener("watchConnect", function(e) {
    Ti.API.info("watchConnect");
});
pebble.addEventListener("watchDisconnect", function(e) {
    Ti.API.info("watchDisconnect");
});

/*
pebble.getVersionInfo(function(e) {
    Ti.API.info("versionInfo");
    Ti.API.info(e);
});


pebble.launchApp(function(e) {
    Ti.API.info("launched app");
});
pebble.killApp(function(e) {
    Ti.API.info("killed app");
});


pebble.appMessageSupported(function(e) {
    Ti.API.info("appMessageSupported");
});

var update = {
    0: 123,
    1: "hello"
};
pebble.pushUpdate({
    update: update,
    
});

pebble.addEventListener("updateReceived", function(e) {
    Ti.API.info("updateReceived");
    Ti.API.info(e);
});
pebble.receiveUpdates(true);

*/