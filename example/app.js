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
var pebble = require('org.beuckman.tipebble');
Ti.API.info("module is => " + pebble);

// this demo uuid is from the pebble documentation
pebble.setAppUUID("226834ae-786e-4302-a52f-6e7efc9f990b");


pebble.addEventListener("watchConnect", function(e) {
    Ti.API.info("watchConnect");
});
pebble.addEventListener("watchDisconnect", function(e) {
    Ti.API.info("watchDisconnect");
});


pebble.getVersionInfo({
    success: function(e) {
        Ti.API.info("versionInfo");
        Ti.API.info(e);
    },
    error: function(e) {
        Ti.API.error(e);
    }
});


/*
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